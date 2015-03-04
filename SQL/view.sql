SELECT
	TableName = d.name ,
	IsTable = CASE WHEN a.column_id = 1 THEN 1 ELSE 0 END,
	ColumnName = a.name,
	ColumnId = a.column_id,
	FieldLength = a.max_length,
	ColumnType = c.name,
	ColumnDesc = b.value,
	a.object_id as ObjectID
FROM
	sys.columns a 
	INNER JOIN sys.types  c on a.user_type_id = c.user_type_id
	left join sys.extended_properties b on a.object_id = b.major_id AND  b.minor_id = a.column_id  AND b.name = 'MS_Description'  
	INNER JOIN sys.views d on d.object_id  = a.object_id
	{Table}
ORDER BY d.name,a.column_id