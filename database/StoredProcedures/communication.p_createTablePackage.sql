/*
name=[communication].[p_createTablePackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2kVjFpPEstNk9FpY8UY4iw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createTablePackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createTablePackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createTablePackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createTablePackage]
@xmlVar XML

AS
/*Procedura tworząca paczkę komunikacyjną z całą zawartością ze wskazanej parametrem tabeli*/
BEGIN
DECLARE
	@count int,
	@i int,
	@command NVARCHAR(max)

	SELECT	@count = x.query(''<e>{ count(entry) } </e>'').value(''e[1]'', ''int''),
			@i = 1
	FROM @xmlVar.nodes(''root'') AS a(x)
	

	WHILE @i <= @count
		BEGIN
			SELECT @command = ''
			INSERT INTO communication.OutgoingXmlQueue (id, localTransactionId, deferredTransactionId, databaseId,  type,xml, creationDate)
			SELECT newid(), '''''' + localTransactionId + '''''', '''''' + deferredTransactionId + '''''' ,'''''' + databaseId + '''''' ,  '''''' + packageName + '''''' ,
			(SELECT ( SELECT ( SELECT * FROM '' + entryName + '' FOR XML PATH(''''entry''''), TYPE ) FOR XML PATH('''''' + (SUBSTRING(entryName, CHARINDEX(''.'',entryName,0) + 1, LEN(entryName)  - CHARINDEX(''.'',entryName,0))) + ''''''), TYPE ) FOR XML PATH(''''root''''), TYPE ), getdate()''
			FROM ( 
				SELECT 
					x.query(''packageName'').value(''.'',''varchar(50)'') packageName, 
					x.query(''localTransactionId'').value(''.'',''char(36)'') localTransactionId, 
					x.query(''deferredTransactionId'').value(''.'',''char(36)'') deferredTransactionId,
					x.query(''databaseId'').value(''.'',''char(36)'') databaseId,
					x.query(''entryName'').value(''.'',''varchar(50)'') entryName
				FROM @xmlVar.nodes(''root/entry[sql:variable("@i")]'') AS a(x)
				) sub

			EXEC(@command)
			SELECT @i = @i + 1
		END

END
' 
END
GO
