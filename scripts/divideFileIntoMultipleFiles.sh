#!/bin/bash

outputFilePrefix="output"
outputFileCounter=1
outputfile="${outputFilePrefix}${outputFileCounter}.txt"

while IFS= read -r line; do
        outputfile="${outputFilePrefix}${outputFileCounter}.txt"
        thisline=$line
        echo $thisline >> $outputfile
        if [[ $line =~ "line" ]]; then
        echo $line
        outputFileCounter=$((outputFileCounter+1))
        echo $outputFileCounter
        fi
done < "test.txt"

##Need a file test.txt which contains multiple word `line` and the script divides the file into multiple with each encounter of word line
