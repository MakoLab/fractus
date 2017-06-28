/*
name=[tools].[getBackupDefaults]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8MPP27VSv2nVOk23VXMpNg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[getBackupDefaults]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[getBackupDefaults]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[getBackupDefaults]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE tools.getBackupDefaults @xmlVar xml
AS
BEGIN 
	DECLARE @branchSymbol varchar(500), @dbname varchar(500), @path varchar(500),@date varchar(50)
	
	SELECT @branchSymbol = symbol , @dbname = db_name(),@date = REPLACE(REPLACE(REPLACE(LEFT(CONVERT( varchar(50),getdate(),120 ),16),'' '',''''),'':'',''''),''-'','''')
	FROM dictionary.Branch 
	WHERE databaseId = (SELECT textValue FROM configuration.COnfiguration WHERE [key] like ''communication.databaseId'')
	
	SELECT @path = textValue FROM configuration.Configuration WHERE [key] = ''system.backupPath''
	
	SELECT  @dbname as ''database'', @path AS ''path'', @dbname+ ''_'' + RTRIM(@branchSymbol) + ''_''+@date+''.bak'' as ''file''
	FOR XML PATH(''root''), TYPE
	
END' 
END
GO
