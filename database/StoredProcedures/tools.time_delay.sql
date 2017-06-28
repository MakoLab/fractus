/*
name=[tools].[time_delay]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fth2KTSiPyY/F65gXiGXZg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[time_delay]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[time_delay]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[time_delay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[time_delay] @@DELAYLENGTH char(9)
AS
DECLARE @@RETURNINFO varchar(255)
BEGIN
   WAITFOR DELAY @@DELAYLENGTH
   SELECT @@RETURNINFO = ''A total time of '' + 
                  SUBSTRING(@@DELAYLENGTH, 1, 3) +
                  '' hours, '' +
                  SUBSTRING(@@DELAYLENGTH, 5, 2) + 
                  '' minutes, and '' +
                  SUBSTRING(@@DELAYLENGTH, 8, 2) + 
                  '' seconds, '' +
                  ''has elapsed! Your time is up.''
   PRINT @@RETURNINFO
END
' 
END
GO
