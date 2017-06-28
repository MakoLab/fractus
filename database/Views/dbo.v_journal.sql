/*
name=[dbo].[v_journal]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FdAv7Ooo8zD3E/53MieX5Q==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_journal]'))
DROP VIEW [dbo].[v_journal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_journal]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW dbo.v_journal
AS
SELECT     TOP (100) PERCENT j.date, j.firstObjectId, j.secondObjectId, j.thirdObjectId, j.xmlParams, j.kernelVersion, ja.name, au.login
FROM         journal.Journal AS j INNER JOIN
                      journal.JournalAction AS ja ON ja.id = j.journalActionId LEFT OUTER JOIN
                      contractor.ApplicationUser AS au ON au.contractorId = j.applicationUserId
ORDER BY j.date DESC
' 
GO
