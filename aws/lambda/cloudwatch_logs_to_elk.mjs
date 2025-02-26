import https from 'https';
import { Buffer } from 'buffer';
import zlib from 'zlib';

const esEndpoint = process.env.ELASTICSEARCH_ENDPOINT;
const esUsername = process.env.ELASTICSEARCH_USERNAME;
const esPassword = process.env.ELASTICSEARCH_PASSWORD;

// Export your function using 'export'
export const handler = async (event, context) => {
    try {
        const logEvents = Array.isArray(event.logEvents) ? event.logEvents : [];

        // Decode the Base64-encoded data field as binary data
        const decodedData = Buffer.from(event.awslogs.data, 'base64');

        // Decompress the gzip payload
        const decompressedData = zlib.unzipSync(decodedData).toString('utf-8');

        // Ensure decompressed data ends with a newline character
        let bulkRequestBody = decompressedData.endsWith('\n') ? decompressedData : decompressedData + '\n';

        // Parse the bulkRequestBody
        let thisEvent = JSON.parse(bulkRequestBody);

        // Ensure each bulk operation is preceded by a newline character and index line
        let parsedData = parseData(thisEvent).map(entry => {
            return '{"index": {"_index": "' + getIndexName(thisEvent.logGroup) + '"}}\n' +
                   JSON.stringify(entry) + '\n';
        }).join('');

        // Log parsedData for debugging
        console.log("Parsed Data for Elasticsearch:", parsedData);

        // Ensure the bulk request body is not empty
        if (!parsedData.trim()) {
            console.error('No valid requests found in parsed data.');
            return;
        }

        // Combine index line and parsedData
        //const finalBulkRequestBody = parsedData;

        //console.log("typeof final bulk request body is ", typeof parsedData);

        // Create index if needed and post data to Elasticsearch
        await createIndexIfNeeded(logEvents);
        await postDataToElasticsearch(parsedData);
    } catch (error) {
        console.error('Error processing logs:', error);
    }
};

function parseData(logs) {
    // Check if logs is an object
    if (typeof logs !== 'object' || logs === null || !logs.logEvents || !Array.isArray(logs.logEvents)) {
        console.error('Invalid logs structure:', logs);
        return [];
    }

    const result = {};
    const indexName = getIndexName(logs.logGroup);

    if (!indexName) {
        console.error('Index name is undefined for logs:', logs);
        return [];
    }

    logs.logEvents.forEach((log, index) => {
        const requestId = log.extractedFields && log.extractedFields.request_id;
        const timestamp = log.extractedFields && log.extractedFields.timestamp;
        const message = log.extractedFields && log.extractedFields.event;

        if (requestId && timestamp && message) {
           // console.log(`Processing log event ${index}:`, log);

            if (!result[requestId]) {
                result[requestId] = {
                    requestId: requestId,
                    messages: []
                };
            }

            result[requestId].messages.push({
                timestamp: timestamp,
                message: message
            });
        } else {
            console.log(`Skipping invalid log event:`, log);
        }
    });

    // Convert the result object to an array
    const resultArray = Object.values(result);

    // console.log("Parsed Result:", resultArray);

    return resultArray;
}





// Export your functions using 'export'
export async function createIndexIfNeeded(logs) {
    const uniqueIndices = new Set(logs.map(log => getIndexName(log)));
    
    for (const indexName of uniqueIndices) {
        try {
            // Ensure the bulk request ends with a newline
            await postDataToElasticsearch(`{"index": {"_index": "${indexName}"}}\n{}\n`);
        } catch (error) {
            console.error(`Error creating index ${indexName}:`, error);
        }
    }
}




export function postDataToElasticsearch(data, path = '/_bulk') {
  //  console.log('Request Body Length:', Buffer.byteLength(data)); // Log the length of the data
   // console.log('Request Body:', data);

    const options = {
        hostname: esEndpoint,
        port: 443,
        path: path,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(data),
            'Authorization': `Basic ${Buffer.from(`${esUsername}:${esPassword}`).toString('base64')}`,
        },
    };

    return new Promise((resolve, reject) => {
        const req = https.request({
            ...options,
            rejectUnauthorized: false, // Add this line to ignore SSL-related errors
        }, res => {
            let responseBody = '';
            res.on('data', chunk => {
                responseBody += chunk;
            });
            res.on('end', () => {
                const info = JSON.parse(responseBody);
                if (res.statusCode >= 200 && res.statusCode < 299) {
                    resolve(info);
                } else {
                    reject(`Elasticsearch request failed: ${JSON.stringify(info)}`);
                }
            });
        });

        req.on('error', error => {
            reject(`Elasticsearch request error: ${error}`);
        });

        // Check if data is not empty before writing to the request
        if (data) {
            req.write(data);
        } else {
            reject('Elasticsearch request error: Request body is empty');
        }

        req.end();
    });
}

function getIndexName(log) {
    const functionName = log.split('/aws/').pop(); // Extract function name from logGroup
    let newIndex = functionName.replace(/\//g, '-').toLowerCase();
    return newIndex;
}

