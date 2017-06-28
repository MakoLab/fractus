/*
name=[translation].[p_insertCompany]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Varp5a1QLneS7zJHZoh6NA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertCompany]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertCompany]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertCompany]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertCompany] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @query NVARCHAR(300)
	
	SELECT @query = ''UPDATE dictionary.Company SET xmlLabels = 
					(SELECT
						(SELECT ''''pl'''' as ''''@lang'''', (SELECT (SELECT LTRIM(RTRIM(nazwa)) FROM [''+@serverName+''].''+@dbName+''.dbo.Dane_Firmy) as label) FOR XML PATH(''''label''''), TYPE)
					FOR XML PATH(''''labels''''), TYPE)''
	EXEC(@query)
END
' 
END
GO
