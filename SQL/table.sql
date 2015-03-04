SELECT 
    TableName = O.name,
    IsTable = CASE WHEN C.column_id = 1 THEN 1 ELSE 0 END,
    ColumnId = C.column_id,
    ColumnName = C.name,
    PrimaryName = ISNULL(IDX.PrimaryKey,N'0'),
    Increasing = CASE WHEN C.is_identity = 1 THEN N'1'ELSE N'0' END,
    Computed = CASE WHEN C.is_computed = 1 THEN N'1'ELSE N'0' END,
    ColumnType = T.name,
    Length = C.max_length,
    Precision = C.precision,
    Scale = C.scale,
    NullAble = CASE WHEN C.is_nullable = 1 THEN N'1'ELSE N'0' END,
    DefaultValue = ISNULL(D.definition,N''),
    ColumnDesc = ISNULL(PFD.[value],N''),
    IndexName = ISNULL(IDX.IndexName,N''),
    IndexSort = ISNULL(IDX.Sort,N''),
    CreateDate = O.Create_Date,
    ModifyDate = O.Modify_date,
	ObjectID = O.object_id
FROM sys.columns C
    INNER JOIN sys.objects O
        ON C.[object_id] = O.[object_id]
            AND O.type = 'U'
            AND O.is_ms_shipped = 0
    INNER JOIN sys.types T
        ON C.user_type_id = T.user_type_id
    LEFT JOIN sys.default_constraints D
        ON C.[object_id] = D.parent_object_id
            AND C.column_id = D.parent_column_id
            AND C.default_object_id = D.[object_id]
    LEFT JOIN sys.extended_properties PFD
        ON PFD.class = 1 
            AND C.[object_id] = PFD.major_id 
            AND C.column_id = PFD.minor_id
    LEFT JOIN sys.extended_properties PTB
        ON PTB.class = 1 
            AND PTB.minor_id = 0 
            AND C.[object_id] = PTB.major_id

    LEFT JOIN                    
    (
        SELECT 
            IDXC.[object_id],
            IDXC.column_id,
            Sort = CASE INDEXKEY_PROPERTY(IDXC.[object_id],IDXC.index_id,IDXC.index_column_id,'IsDescending')
                WHEN 1 THEN 'DESC' WHEN 0 THEN 'ASC' ELSE '' END,
            PrimaryKey = CASE WHEN IDX.is_primary_key = 1 THEN N'1'ELSE N'0' END,
            IndexName = IDX.Name
        FROM sys.indexes IDX
        INNER JOIN sys.index_columns IDXC
            ON IDX.[object_id] = IDXC.[object_id]
                AND IDX.index_id = IDXC.index_id
        LEFT JOIN sys.key_constraints KC
            ON IDX.[object_id] = KC.[parent_object_id]
                AND IDX.index_id = KC.unique_index_id
        INNER JOIN 
        (
            SELECT [object_id], Column_id, index_id = MIN(index_id)
            FROM sys.index_columns
            GROUP BY [object_id], Column_id
        ) IDXCUQ
            ON IDXC.[object_id] = IDXCUQ.[object_id]
                AND IDXC.Column_id = IDXCUQ.Column_id
                AND IDXC.index_id = IDXCUQ.index_id
    ) IDX
        ON C.[object_id] = IDX.[object_id]
            AND C.column_id = IDX.column_id
	{Table}
ORDER BY O.name,C.column_id