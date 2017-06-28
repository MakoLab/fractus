/*
name=[journal].[p_getJournalEntries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ricEqrRp3WKrq0gf2W0IgQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[journal].[p_getJournalEntries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [journal].[p_getJournalEntries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[journal].[p_getJournalEntries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [journal].[p_getJournalEntries] @xmlVar XML
as
BEGIN

DECLARE @sql varchar(max),
	    @fromDate NVARCHAR(50),
		@toDate NVARCHAR(50),
		@applicationUserId NVARCHAR(50),
		@actionId NVARCHAR(50)
	
	SELECT	@fromDate = NULLIF(@xmlVar.value(''(root/searchParam/@fromDate)[1]'',''varchar(50)''),''''),
			@toDate = NULLIF(@xmlVar.value(''(root/searchParam/@toDate)[1]'',''varchar(50)'') ,''''),
			@applicationUserId = NULLIF(@xmlVar.value(''(root/searchParam/@applicationUserId)[1]'',''varchar(50)'') ,''''),
			@actionId = NULLIF(@xmlVar.value(''(root/searchParam/@journalActionId)[1]'',''varchar(50)''),'''')
	
	
	--SELECT @fromDate, @toDate, @applicationUserId, @actionId

	SELECT @sql = ''
	 SELECT  (
		SELECT ja.name,a.login, j.date, j.xmlParams
		FROM journal.Journal j 
			JOIN journal.JournalAction ja ON j.journalActionId = ja.id
			JOIN contractor.ApplicationUser a ON j.applicationUserId = a.contractorId
		WHERE 1 = 1 '' +
			CASE WHEN @fromDate IS NOT NULL THEN '' AND j.date >= ''''''+ @fromDate + '''''' '' ELSE '''' END +
			CASE WHEN @toDate IS NOT NULL THEN '' AND j.date <= '''''' + @toDate + '''''' '' ELSE '''' END +
			CASE WHEN @applicationUserId IS NOT NULL THEN '' AND j.applicationUserId = '''''' + @applicationUserId + '''''' '' ELSE '''' END +
			CASE WHEN @actionId IS NOT NULL THEN '' AND j.journalActionId = '''''' + @actionId + '''''' '' ELSE '''' END + 
		
		'' FOR XML PATH(''''entry''''),TYPE
					) FOR XML PATH(''''root''''),TYPE''
	EXEC(@SQL)
END
' 
END
GO
