
DECLARE
    @schemaName sysname,
    @tableName sysname,
    @compressionType VARCHAR(50),
    @sql NVARCHAR(1000)

DECLARE table_cursor CURSOR FAST_FORWARD
FOR
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    p.data_compression_desc AS CompressionType
FROM
    sys.partitions AS p
    INNER JOIN sys.tables AS t ON t.object_id = p.object_id
WHERE
    p.index_id IN (0, 1)

OPEN table_cursor

FETCH NEXT FROM table_cursor
INTO @schemaName, @tableName, @compressionType

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'ALTER INDEX ALL ON [' + @schemaName + '].[' + @tableName + '] REBUILD'
        + CASE WHEN @compressionType <> 'NONE' 
            THEN ' PARTITION = ALL WITH(DATA_COMPRESSION = ' + @compressionType + ')'
            ELSE ''
          END

    PRINT @sql
    EXEC sys.sp_executesql @SQL

    FETCH NEXT FROM table_cursor   
    INTO @schemaName, @tableName, @compressionType
END

CLOSE table_cursor;  
DEALLOCATE table_cursor;  