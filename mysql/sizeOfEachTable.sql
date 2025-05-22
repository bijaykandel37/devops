SELECT 
     table_schema as `Database`, 
     table_name AS `Table`, 
     ROUND(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` 
FROM information_schema.TABLES 
WHERE table_schema = 'processmaker'
ORDER BY (data_length + index_length) DESC;

