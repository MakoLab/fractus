/*
name=[document].[p_commercialDocumentDictionaryRebuild]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
G9PwKDIr+LphLy973wYPxg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_commercialDocumentDictionaryRebuild]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_commercialDocumentDictionaryRebuild]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_commercialDocumentDictionaryRebuild]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_commercialDocumentDictionaryRebuild]

AS
DECLARE
@commercialDocumentHeaderId  UNIQUEIDENTIFIER,
@dok XML,
@a VARCHAR(500)


	IF OBJECT_ID(''tmp_tableSplit'',''U'') IS NULL
	CREATE TABLE tmp_tableSplit ( id UNIQUEIDENTIFIER, a NVARCHAR(100))
	ELSE TRUNCATE TABLE tmp_tableSplit

DECLARE op   CURSOR FAST_FORWARD FOR 
SELECT id, REPLACE(a,''"'','' '')  
FROM (
	SELECT c.[fullName] a , h.id FROM [document].[CommercialDocumentHeader] h JOIN [Contractor].[Contractor] c ON h.[contractorId] = c.id
	UNION
	SELECT fullNumber a,id FROM [document].CommercialDocumentHeader 
	UNION
	SELECT itemName a,commercialDocumentHeaderId FROM  document.CommercialDocumentLine
	UNION
	SELECT city a ,h.id FROM  [document].CommercialDocumentHeader h WITH(NOLOCK) JOIN [contractor].[ContractorAddress] ca1 WITH(NOLOCK)  ON h.issuerContractorAddressId = ca1.[id]
	UNION
	SELECT city a,h.id FROM  [document].CommercialDocumentHeader h WITH(NOLOCK)  JOIN [contractor].[ContractorAddress] ca1 WITH(NOLOCK)  ON h.contractorAddressId = ca1.[id]
	UNION
	SELECT address a,h.id FROM  [document].CommercialDocumentHeader h WITH(NOLOCK)  JOIN [contractor].[ContractorAddress] ca1 WITH(NOLOCK)  ON h.contractorAddressId = ca1.[id]
	UNION
	SELECT address a,h.id FROM  [document].CommercialDocumentHeader h WITH(NOLOCK)  JOIN [contractor].[ContractorAddress] ca1 WITH(NOLOCK)  ON h.issuerContractorAddressId = ca1.[id]
) x
WHERE a <> ''''
ORDER BY 1



OPEN op
FETCH NEXT FROM op INTO @commercialDocumentHeaderId ,@a
WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	INSERT INTO tmp_tableSplit(id,a)
	SELECT @commercialDocumentHeaderId, * 
	FROM dbo.f_TOOLS_Split(@a,'' '')

FETCH NEXT FROM op INTO @commercialDocumentHeaderId ,@a

END CLOSE op DEALLOCATE op

/*Wstawienia słów kluczowych*/
INSERT INTO [document].CommercialDocumentDictionary (id, field)
SELECT NEWID(),a 
FROM tmp_tableSplit 
WHERE a IS NOT NULL
GROUP BY a

INSERT INTO [document].[CommercialDocumentDictionaryRelation] 
SELECT NEWID(),ts.id,cdd.id FROM tmp_tableSplit ts 
JOIN [document].[CommercialDocumentDictionary] cdd ON ts.a = cdd.[field]
WHERE ts.a IS NOT NULL
' 
END
GO
