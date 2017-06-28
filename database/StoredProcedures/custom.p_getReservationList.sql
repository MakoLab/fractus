/*
name=[custom].[p_getReservationList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8omqZ+yrwdFJfMDLqce1Mg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getReservationList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getReservationList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getReservationList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_getReservationList] -- ''<root/>''
@xmlVar XML
AS
BEGIN
	DECLARE @orderNumber uniqueidentifier ,@orderStatus uniqueidentifier, @errorMsg varchar(2000)

	SELECT @orderStatus = id FROM dictionary.DocumentField WHERE name like ''Attribute_OrderStatus''
	IF @@rowcount = 0 
		BEGIN
			SET @errorMsg = ''Brak atrybutu:Attribute_OrderStatus , atrybut wymagany do działania funkcji ; ''
			RAISERROR ( @errorMsg, 16, 1 );
			--RETURN 0;
		END

	SELECT @orderNumber = id FROM dictionary.DocumentField WHERE name like ''Attribute_OrderNumber''
	IF @@rowcount = 0 
		BEGIN
			SET @errorMsg = ''Brak atrybutu:Attribute_OrderNumber , atrybut wymagany do działania funkcji ; ''
			RAISERROR ( @errorMsg, 16, 1 );
			--RETURN 0;
		END
		
	SELECT (			
		SELECT distinct h.fullNumber orderNumber,h.issueDate orderDate, clientOrder.fullNumber clientReservationNumber, clientOrder.issueDate reservationDate, l.itemId,i.name itemName, l.quantity, orderNumber.textValue orderNumber 
		FROM document.CommercialDocumentHeader h
			JOIN document.CommercialDocumentLine l ON h.id = l.commercialDocumentHeaderId
			JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
			JOIN document.DocumentAttrValue a ON h.id = a.commercialDocumentHeaderId
			LEFT JOIN document.DocumentAttrValue orderNumber ON h.id = orderNumber.commercialDocumentHeaderId AND orderNumber.documentFieldId = @orderNumber
			/*Tutaj pobieram zamówienie klienta po numerze z atrybutu*/
			LEFT JOIN ( SELECT dav.textValue ,  cdh.id, cdh.contractorId, cdh.fullNumber, cdh.issueDate
						FROM document.DocumentAttrValue dav
							JOIN document.CommercialDocumentHeader cdh ON dav.commercialDocumentHeaderId  = cdh.id
							JOIN dictionary.DocumentType t ON cdh.documentTypeId = t.id
						WHERE dav.documentFieldId = @orderNumber  and t.documentCategory = 3
					) clientOrder ON orderNumber.textValue = clientOrder.textValue  AND NULLIF( h.id , clientOrder.id) IS NOT NULL	
			JOIN item.Item i ON l.itemId = i.id					
		WHERE dt.symbol = ''ZAM''
			AND a.documentFieldId = @orderStatus
			AND a.textValue = ''1'' --Status zamówienia zrealizowany
			AND orderNumber.documentFieldId = @orderNumber
		FOR XML PATH(''line''),TYPE )
	FOR XML PATH(''reservationList''),TYPE		
END
' 
END
GO
