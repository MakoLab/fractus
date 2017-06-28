/*
name=[document].[p_getLatestDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yjc9t/HlUerwmgZpzm9SoA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getLatestDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getLatestDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getLatestDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getLatestDocuments]
------------ procedura dla zestawień na urządzenia mobilne ---------
AS
-- wiersze
SELECT TOP 10
	H.fullNumber [Numer],
	C.shortName [Kontr.],
	H.netValue [Wart. netto],
	H.grossValue [Wart. brutto],
	H.issueDate [Data wyst.]
FROM
	document.CommercialDocumentHeader H
	LEFT JOIN contractor.Contractor C ON C.id = H.contractorId
ORDER BY H.issueDate DESC

-- podsumowanie
SELECT ''SUMA'', '''', 	SUM(netValue), SUM(grossValue), ''''
FROM
(
SELECT TOP 10
	H.netValue,
	H.grossValue
FROM
	document.CommercialDocumentHeader H
	LEFT JOIN contractor.Contractor C ON C.id = H.contractorId
ORDER BY H.issueDate DESC
) X
' 
END
GO
