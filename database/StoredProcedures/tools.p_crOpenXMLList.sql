/*
name=[tools].[p_crOpenXMLList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
kzPEhOsx+Xh13PYtWk0uhA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_crOpenXMLList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_crOpenXMLList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_crOpenXMLList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_crOpenXMLList] -- ''WarehouseDocumentHeader'', ''document''
 
@TABLE varchar(500), 
@schema varchar(500),
@type char(1)
 
AS
 
BEGIN
	DECLARE 
	@out varchar(max),
	@list varchar(max) 
 
 
 IF @type = ''X''
	 SELECT ( CAST(
	 (SELECT ''['' + name + ''] '' + CASE WHEN DataType IN (''int'', ''bit'',''uniqueidentifier'', ''money'', ''datetime'') THEN REPLACE(DataType,''uniqueidentifier'', ''char(36)'') ELSE DataType + ''('' + length + '','' + numericPrecision + '')'' END  + '' '''''' + name + '''''','' AS ''data()'' 
	 FROM (
		SELECT
			clmns.name AS [Name],
			usrt.name AS [DataType],
			ISNULL(baset.name,'''') AS [SystemType],
			CAST(CASE WHEN baset.name IN (''nchar'', ''nvarchar'') AND clmns.max_length <> -1 THEN clmns.max_length/2 ELSE clmns.max_length END AS varchar(500)) AS [Length],
			CAST(clmns.precision AS varchar(500)) AS [NumericPrecision],
			CAST(clmns.scale AS int) AS [NumericScale]
		FROM
			sys.tables AS tbl
			INNER JOIN sys.all_columns AS clmns ON clmns.object_id=tbl.object_id
			LEFT OUTER JOIN sys.indexes AS ik ON ik.object_id = clmns.object_id and 1=ik.is_primary_key
			LEFT OUTER JOIN sys.index_columns AS cik ON cik.index_id = ik.index_id and cik.column_id = clmns.column_id and cik.object_id = clmns.object_id and 0 = cik.is_included_column
			LEFT OUTER JOIN sys.types AS usrt ON usrt.user_type_id = clmns.user_type_id
			LEFT OUTER JOIN sys.types AS baset ON (baset.user_type_id = clmns.system_type_id and baset.user_type_id = baset.system_type_id) 
		WHERE
			(tbl.name= @TABLE and SCHEMA_NAME(tbl.schema_id)= @schema)
	 ) xx FOR XML PATH(''''), TYPE)
	 as varchar(max)))
 ELSE IF @type = ''U''


	SELECT ( CAST(
	( SELECT ''['' + name + ''] = CASE WHEN con.exist('''''' +name+'''''') = 1 THEN con.query('''''' +name+'''''').value(''''.'''','''''' + CASE WHEN DataType IN (''int'', ''bit'',''uniqueidentifier'', ''money'', ''datetime'') THEN REPLACE(DataType,''uniqueidentifier'', ''char(36)'') ELSE DataType + ''('' + length + '','' + numericPrecision + '') ''  END + '''''') ELSE NULL END ,'' AS ''data()'' 
		 FROM (
			SELECT
				clmns.name AS [Name],
				usrt.name AS [DataType],
				ISNULL(baset.name,'''') AS [SystemType],
				CAST(CASE WHEN baset.name IN (''nchar'', ''nvarchar'') AND clmns.max_length <> -1 THEN clmns.max_length/2 ELSE clmns.max_length END AS varchar(500)) AS [Length],
				CAST(clmns.precision AS varchar(500)) AS [NumericPrecision],
				CAST(clmns.scale AS int) AS [NumericScale]
			FROM
				sys.tables AS tbl
				INNER JOIN sys.all_columns AS clmns ON clmns.object_id=tbl.object_id
				LEFT OUTER JOIN sys.indexes AS ik ON ik.object_id = clmns.object_id and 1=ik.is_primary_key
				LEFT OUTER JOIN sys.index_columns AS cik ON cik.index_id = ik.index_id and cik.column_id = clmns.column_id and cik.object_id = clmns.object_id and 0 = cik.is_included_column
				LEFT OUTER JOIN sys.types AS usrt ON usrt.user_type_id = clmns.user_type_id
				LEFT OUTER JOIN sys.types AS baset ON (baset.user_type_id = clmns.system_type_id and baset.user_type_id = baset.system_type_id) 
			WHERE
				(tbl.name= @TABLE and SCHEMA_NAME(tbl.schema_id)= @schema)
		 ) xx FOR XML PATH(''''), TYPE)
		 as varchar(max)))

END
' 
END
GO
