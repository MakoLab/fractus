/*
name=[tools].[p_testValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
l4x3TalC1iUugi0AWsP+PQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_testValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_testValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_testValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_testValue]

AS
select null
/*
SELECT  fullNumber,textValue, nrPelny ,wartNetto, wartBrutto, wartVat, koszt, netValue, grossValue, vatValue,cost
FROM (
	SELECT h.netValue, h.grossValue, h.vatValue,isnull(l.cost ,0) cost ,h.fullNumber ,h.eventDate, da.textValue, dt.symbol
	FROM document.CommercialDocumentHeader h
		JOIN (
				SELECT  cl.commercialDocumentHeaderId , SUM( cv.value) cost
				FROM document.CommercialDocumentLine cl
					LEFT JOIN document.CommercialWarehouseValuation cv ON cl.id = cv.commercialDocumentLineId
				GROUP BY cl.commercialDocumentHeaderId 
			) l ON h.id = l.commercialDocumentHeaderId
		JOIN document.DocumentAttrValue da ON h.id = da.commercialDocumentHeaderId
		JOIN dictionary.DocumentField df ON da.documentFieldId = df.id AND df.name = ''Attribute_F1Id''
		JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
	) f2 
LEFT JOIN (
		SELECT dn.wartNetto, dn.wartBrutto, dn.wartVat, dn.koszt , dn.nrPelny , dn.id, dt.typ
		FROM [192.168.1.254].MegaManage.dbo.dok_naglowek dn
			JOIN [192.168.1.254].MegaManage.dbo.dok_typy dt ON dn.idtyp = dt.id
		) f1 ON SUBSTRING(f2.textValue, CHARINDEX ( ''/'', f2.textValue,0) + 1 , LEN(f2.textValue) - CHARINDEX ( ''/'', f2.textValue,0) ) = f1.nrpelny
			and f1.typ = f2.symbol --LIKE SUBSTRING( f2.textValue, 0, CHARINDEX ( ''/'', f2.textValue,0))

WHERE ISNULL(netValue,0) <> ISNULL(wartNetto, 0) OR ISNULL(grossValue,0) <> ISNULL(wartBrutto,0)  
	OR ISNULL(vatValue,0) <> ISNULL(wartVat,0) OR ISNULL(cost,0) <> ISNULL(koszt,0)

*/
' 
END
GO
