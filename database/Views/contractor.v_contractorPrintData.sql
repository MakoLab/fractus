/*
name=[contractor].[v_contractorPrintData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bvy2fLnkgTqCa1X9aqFD8Q==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorPrintData]'))
DROP VIEW [contractor].[v_contractorPrintData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorPrintData]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [contractor].[v_contractorPrintData]
WITH SCHEMABINDING
AS
SELECT id, (
	SELECT 
		c.version,
		c.id,
		c.isSupplier,
		c.isReceiver,
		c.isBusinessEntity,
		c.isBank,
		c.isEmployee,
		c.isOwnCompany,
		c.code,
		c.fullName,
		c.shortName,
		c.nipPrefixCountryId,
		c.nip,
		(SELECT (	SELECT
						ca.id,
						ca.contractorId,
						ca.contractorFieldId,
						ca.countryId,
						ca.city,
						ca.postCode,
						ca.postOffice,
						ca.[address],
						ca.[version],
						ca.[order]
					FROM contractor.ContractorAddress ca  WITH (NOLOCK)
					WHERE ca.contractorId = c.id
					FOR XML PATH(''address''), TYPE )
				FOR XML PATH(''addresses''), TYPE ),
		(SELECT (	SELECT
						ca.id,
						ca.contractorId,
						ca.contractorFieldId,
						ca.decimalValue,
						ca.dateValue,
						ca.textValue,
						ca.xmlValue,
						ca.[version],
						ca.[order]
					FROM contractor.ContractorAttrValue ca  WITH (NOLOCK)
					WHERE ca.contractorId = c.id
					FOR XML PATH(''attribute''), TYPE )
				FOR XML PATH(''attributes''), TYPE ),
		(SELECT (	SELECT
						ca.id,
						ca.contractorId,
						ca.bankContractorId,
						ca.accountNumber,
						ca.[version],
						ca.[order]
					FROM contractor.ContractorAccount ca  WITH (NOLOCK)
					WHERE ca.contractorId = c.id
					FOR XML PATH(''account''), TYPE )
				FOR XML PATH(''accounts''), TYPE ),
		(SELECT (	SELECT
						ca.id,
						ca.contractorId,
						ca.contractorRelationTypeId,
						ca.[version],
						ca.[order],
						( SELECT
							( SELECT 
										cr.version,
										cr.id,
										cr.isSupplier,
										cr.isReceiver,
										cr.isBusinessEntity,
										cr.isBank,
										cr.isEmployee,
										cr.isOwnCompany,
										cr.fullName,
										cr.shortName,
										cr.nipPrefixCountryId,
										cr.nip
								FROM contractor.Contractor cr WITH(NOLOCK)
								WHERE ca.relatedContractorId = cr.id
								FOR XML PATH(''contractor''), TYPE
							) FOR XML PATH(''relatedContractor''), TYPE
						 )
					FROM contractor.ContractorRelation ca  WITH (NOLOCK)
					WHERE ca.contractorId = c.id
					FOR XML PATH(''relation''), TYPE )
				FOR XML PATH(''relations''), TYPE )
				
	FROM contractor.Contractor c  WITH (NOLOCK)
	WHERE c.id = cc.id
	FOR XML PATH(''contractor''), TYPE ) xmlValue
FROM contractor.Contractor cc;
' 
GO
