SELECT 
	TableName = a.name,
	IsTable = CASE WHEN b.colid = 1 THEN 1 ELSE 0 END,
	ColumnName = replace(b.name,'@',''),
	ColumnId = b.colid,
	ColumnType = c.name,
	FieldLength = b.length,
	a.object_id as ObjectID
FROM 
	sys.objects a
	inner join syscolumns b
	on a.object_id = b.id
	inner join systypes c
	on b.xtype = c.xtype
Where a.type = 'p'
		AND c.name<>'sysname'
	{Table}
ORDER BY a.name,b.colid