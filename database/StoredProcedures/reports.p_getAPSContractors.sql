/*
name=[reports].[p_getAPSContractors]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UuKObGMmtl1heWPAhNvIlg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getAPSContractors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getAPSContractors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getAPSContractors]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [reports].[p_getAPSContractors] @xmlVar XML
AS
BEGIN
DECLARE @return XML
--DECLARE @tmp TABLE (id uniqueidentifier

SELECT @return = (
	SELECT * FROM (
		SELECT  c.fullName, c.shortName, ca.city, ca.postCode, ca.address, c.nip, ema.textValue [email],
		CASE WHEN  cg.label = ''APS Aktywne'' THEN ''A'' WHEN cg.label =  ''APS Nieaktywne'' THEN ''N'' END label,
		(SELECT STUFF( (SELECT name + '',''  FROM  item.PriceRule WHERE definition.value(''(root/conditions/condition[@name="contractors"]/value)[1]'',''varchar(max)'') IS NOT NULL AND c.id IN ( SELECT * FROM dbo.xp_split(NULLIF(definition.value(''(root/conditions/condition[@name="contractors"]/value)[1]'',''varchar(max)''),''''),'','')) FOR XML PATH('''')), 1, 0, '''') ) priceRule,
		 pm.xmlLabels.value(''(labels/label)[1]'',''varchar(500)'') paymentMethod, ROUND(cam.decimalValue,2)  MaxDebtAmount,
		 CASE WHEN pay.decimalValue = 0 THEN ''Nie'' WHEN pay.decimalValue = 1 THEN ''Tak'' END AllowCashPayment,
		 -1*(SELECT SUM(p.unsettledAmount * p.direction) FROM finance.Payment p WITH(NOLOCK) WHERE ISNULL(p.requireSettlement, 1) = 1 AND p.unsettledAmount <> 0 AND p.contractorId = c.id) paymentBalance,
		 -1*(SELECT SUM(ISNULL(p.unsettledAmount, p.amount) * p.direction) FROM finance.Payment p WITH(NOLOCK) WHERE ISNULL(p.requireSettlement, 1) = 1 AND p.unsettledAmount <> 0 AND p.contractorId = c.id AND p.dueDate < DATEADD(dd, -1, GETDATE()) AND p.direction*p.amount < 0) untermPaymentBalance,
		 (
			SELECT SUM(l.grossValue - isnull(X.realizedValue, 0))
			FROM document.CommercialDocumentHeader h
			JOIN document.CommercialDocumentLine l on l.commercialDocumentHeaderId = h.id
			LEFT JOIN
			(
				SELECT dav.guidValue as orderLineId, SUM(-sl.commercialDirection * sl.grossValue) as realizedValue
				FROM document.CommercialDocumentLine sl
				LEFT JOIN document.DocumentLineAttrValue dav ON sl.id = dav.commercialDocumentLineId
				WHERE dav.documentFieldId = ''AA6AE7B0-B67B-4D76-89D8-0DF24CB9B58F''
				GROUP BY dav.guidValue
			) X ON X.orderLineId = l.id
			JOIN dictionary.DocumentType dt ON h.documentTypeId = dt.id
			WHERE h.status = 20 AND h.contractorId = c.id
		) salesOrders
		from contractor.Contractor c 
			LEFT JOIN contractor.ContractorAddress ca ON c.id = ca.contractorId AND ca.contractorFieldId = (SELECT id FROM dictionary.contractorField WHERE name=''Address_Default'')
			LEFT JOIN contractor.ContractorGroupMembership cgm ON c.id = cgm.contractorId 
			LEFT JOIN contractor.ContractorGroup cg ON cgm.contractorGroupId = cg.id
			LEFT JOIN contractor.ContractorAttrValue cav ON c.id = cav.contractorId and cav.contractorFieldId = (SELECT id FROM dictionary.ContractorField where name = ''Attribute_DefaultPaymentMethod'')
			LEFT JOIN dictionary.PaymentMethod pm ON CAST(cav.textValue AS uniqueidentifier) = pm.id 
			LEFT JOIN contractor.ContractorAttrValue cam ON c.id = cam.contractorId and cam.contractorFieldId = (SELECT id FROM dictionary.ContractorField where name = ''SalesLockAttribute_MaxDebtAmount'')
			LEFT JOIN contractor.ContractorAttrValue pay ON c.id = pay.contractorId and pay.contractorFieldId = (SELECT id FROM dictionary.ContractorField where name = ''SalesLockAttribute_AllowCashPayment'')
			LEFT JOIN contractor.ContractorAttrValue ema ON c.id = ema.contractorId and ema.contractorFieldId = (SELECT id FROM dictionary.ContractorField where name = ''Contact_Email'')
		WHERE cg.id IN (''FC0F7D23-E151-4D78-9C66-3B159784F073'', ''628DB63B-E20B-4E2B-AB64-FD05DBAEC185'')
	) line  FOR XML AUTO)


SELECT  @return FOR XML PATH(''root''),TYPE 
END
' 
END
GO
