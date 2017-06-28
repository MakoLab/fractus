/*
name=[print].[p_getInventorySheetPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JagxiNuzh2wioeSSXiBtfA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getInventorySheetPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getInventorySheetPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getInventorySheetPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [print].[p_getInventorySheetPrint]
@documentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

SELECT (
	SELECT (
		SELECT ( 	
				SELECT  s.ordinalNumber,s.direction, u.xmlLabels.value(''(labels/label[@lang = "pl"]/@symbol)[1]'', ''varchar(50)'') unitSymbol,
				i.name itemName, i.code itemCode, s.systemQuantity, s.userQuantity
				FROM document.InventorySheetLine  s 
					JOIN item.Item i ON s.itemId = i.id
					JOIN dictionary.Unit u ON s.unitId = u.id
				WHERE s.inventorySheetId = @documentHeaderId 
				ORDER BY s.ordinalNumber
				FOR XML PATH(''line''), TYPE )
		FOR XML PATH(''lines''), TYPE ),
		
		(SELECT c.fullName, c.shortName, c.nip, ca.city, ca.postCode, ca.postOffice, ca.Address
		FROM contractor.Contractor c
			JOIN contractor.ContractorAddress ca ON c.id = ca.contractorId
			JOIN dictionary.ContractorField cf ON cf.name = ''Address_Default'' AND ca.contractorFieldId = cf.id
		WHERE isOwnCompany = 1
		FOR XML PATH(''ownCompany''), TYPE),
		
		(SELECT h.fullNumber inventoryDocumentFullNumber, ise.creationDate, ise.ordinalNumber ,w.symbol warehouse
		FROM document.InventorySheet  ise
			JOIN document.InventoryDocumentHeader h ON h.id = ise.inventoryDocumentHeaderId
			JOIN dictionary.Warehouse w ON  ise.warehouseId = w.id
		WHERE ise.id = @documentHeaderId
		FOR XML PATH(''inventorySheet''), TYPE)
				
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO
