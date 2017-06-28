/*
name=[translation].[p_insertIssuePlace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
A3TJm9DXGgJGgXW5qw44Dg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertIssuePlace]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertIssuePlace]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertIssuePlace]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create PROCEDURE [translation].[p_insertIssuePlace] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@counter NUMERIC,
			@query NVARCHAR(500)
	
	DELETE FROM dictionary.IssuePlace
	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(lokalizacja)) as nazwa FROM [''+@serverName+''].''+@dbName+''.dbo.Punkty''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = @counter + 1
		INSERT INTO dictionary.IssuePlace([id],[name], [version], [order])
		SELECT	
			NEWID() as [id],
			(SELECT @nazwa) as [name],
			NEWID()as [version],
			(SELECT @counter) as [order]	
		FETCH FROM c INTO @nazwa
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO
