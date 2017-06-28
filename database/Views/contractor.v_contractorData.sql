/*
name=[contractor].[v_contractorData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MV2nNdc18WjRNr+nMFJJkw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorData]'))
DROP VIEW [contractor].[v_contractorData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[contractor].[v_contractorData]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [contractor].[v_contractorData]
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
		c.fullName,
		c.shortName,
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
				FOR XML PATH(''addresses''), TYPE )
	FROM contractor.Contractor c  WITH (NOLOCK)
	WHERE c.id = cc.id
	FOR XML PATH(''contractor''), TYPE ) xmlValue
FROM contractor.Contractor cc;
' 
GO
