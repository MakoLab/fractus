/*
name=[tools].[checkDbState]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qQCVtfpVdFfqhxM635Y8nA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[checkDbState]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[checkDbState]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[checkDbState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[checkDbState] @x XML OUTPUT
AS
BEGIN

	DECLARE  @DriveSpace TABLE ( 
		Drive char(1), 
		MBFree int 
	) 
	 
	INSERT INTO @DriveSpace 
	EXEC xp_fixeddrives
SELECT @x = (
		
	SELECT getdate() AS ''@reportDate'',
		( SELECT ( 
			SELECT drive as ''@drive'' ,MBFree as ''@MBFree''
			FROM @DriveSpace
			FOR XML PATH(''discs''),TYPE )
		FOR XML PATH(''discSpace''),TYPE )
		,
	( SELECT	
		(SELECT t.name as ''@DBName'',t.user_access_desc as ''@AccessState'', t.state_desc as ''@Online_Offline'', 
			((SELECT (CASE t.is_in_standby WHEN 0 THEN ''No'' WHEN 1 THEN ''Yes'' ELSE ''Other'' END))) as ''@InStandby'',
			(COALESCE(Convert(datetime, MAX(u.backup_finish_date), 101),''Not Yet Taken'')) as ''@LastBackUp'',
			CAST ((((COALESCE(Convert(real(256), MAX(u.backup_size), 101),''NA''))/1024)/1024)  AS varchar(50))as ''@BackupSize_MB''
		FROM SYS.DATABASES t
			JOIN msdb.dbo.BACKUPSET u ON t.name = u.database_name
		GROUP BY t.Name,t.is_in_standby, t.user_access_desc, t.state_desc
		ORDER BY t.Name
		FOR XML PATH(''databases''),TYPE)
		FOR XML PATH(''backups''),TYPE) 
	,
		(SELECT 
			(SELECT COUNT(id) FROM communication.OutgoingXmlQueue WITH(NOLOCK) WHERE sendDate IS NULL)  ''@packageNotSend'', 
			(SELECT min(receiveDate) FROM communication.IncomingXmlQueue WITH(NOLOCK) WHERE executionDate IS NULL) ''@oldestPackage'', 
			(SELECT COUNT(id) FROM communication.IncomingXmlQueue WITH(NOLOCK) WHERE executionDate IS NULL)   ''@packageNotExecuted''
		FOR XML PATH(''communication''),TYPE)
	 FOR XML PATH(''report''),TYPE
)

END' 
END
GO
