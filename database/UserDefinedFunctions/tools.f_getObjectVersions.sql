/*
name=[tools].[f_getObjectVersions]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
sov7MMRWXSeS+WS+2QmLmA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[f_getObjectVersions]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [tools].[f_getObjectVersions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[f_getObjectVersions]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [tools].[f_getObjectVersions] ()
returns xml
AS
BEGIN
DECLARE @x XML, @data varchar(50)

SELECT @data =CONVERT(varchar(50),getdate(),120)
	SELECT @x = (
		SELECT @data as ''@data'',(
				SELECT object.type typ, SCHEMA_NAME(object.uid) + ''.'' + ISNULL(object.name,'''') name , 
				 dbo.xp_agregate(SCHEMA_NAME(object.uid) + ISNULL(object.name,'''') + ISNULL(columns.name,'''') + ISNULL(type.name,'''') +
					 ISNULL(CAST(type.prec as varchar(50)),'''') +  ISNULL(type.COLLATION ,'''') + ISNULL(body.text,'''')) _CHECKSUM
				FROM sysobjects object 
					LEFT JOIN syscolumns columns ON object.id = columns.id
					LEFT JOIN systypes type ON columns.xtype = type.xtype
					LEFT JOIN syscomments body ON object.id =  body.id
				WHERE object.type IN (''U'',''FN'',''IF'', ''P'', ''TF'',  ''V'')
				GROUP BY object.type, object.name, object.uid
				ORDER BY object.type
				FOR XML PATH(''entry'') ,TYPE
		) FOR XML PATH(''root''), TYPE	
	)	
RETURN @x
END
' 
END

GO
