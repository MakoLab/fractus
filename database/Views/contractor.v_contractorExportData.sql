/*
name=[contractor].[v_contractorExportData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1x9YvkXA5A8mE1a6mPMCFg==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorExportData]'))
DROP VIEW [contractor].[v_contractorExportData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorExportData]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorExportData]
WITH SCHEMABINDING
AS
SELECT id, (
	SELECT 
		c.version,
		c.id,
		c.isSupplier,
		c.isReceiver,
		c.isBusinessEntity,
		c.code,
		c.fullName,
		c.shortName,
		c.nip,
		(SELECT (	SELECT
						(SELECT x.xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(500)'') FROM dictionary.ContractorField x WHERE x.id = ca.contractorFieldId) addressType,
						(SELECT x.xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(500)'') FROM dictionary.Country x WHERE x.id = ca.countryId) country,
						ca.city,
						ca.postCode,
						ca.postOffice,
						ca.[address]
					FROM contractor.ContractorAddress ca  WITH (NOLOCK)
					WHERE ca.contractorId = c.id
					FOR XML PATH(''address''), TYPE )
				FOR XML PATH(''addresses''), TYPE ),
		(SELECT (	SELECT
						(SELECT x.xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(500)'') FROM dictionary.ContractorField x WHERE x.id = ca.contractorFieldId) attributeType,
						ca.decimalValue,
						ca.dateValue,
						ca.textValue,
						ca.xmlValue
					FROM contractor.ContractorAttrValue ca  WITH (NOLOCK)
					WHERE ca.contractorId = c.id
					FOR XML PATH(''attribute''), TYPE )
				FOR XML PATH(''attributes''), TYPE )
	FROM contractor.Contractor c  WITH (NOLOCK)
	WHERE c.id = cc.id
	FOR XML PATH(''contractor''), TYPE ) xmlValue
FROM contractor.Contractor cc;
' 
GO
