/*
name=[tools].[log]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hFZabKJ9vfqNoXO86ohKFA==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tools].[log]'))
DROP VIEW [tools].[log]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tools].[log]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [tools].[log]
AS
SELECT postTime, DB_User, Event, TSQL, eventdata_.value(''(EVENT_INSTANCE/SchemaName)[1]'',''varchar(50)'') [schema], eventdata_.value(''(EVENT_INSTANCE/ObjectName)[1]'',''varchar(50)'') [ObjectName] 
FROM ddl_log
' 
GO
