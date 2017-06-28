/*
name=[contractor].[p_deleteContractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZDD4I4X9Smxt0tU4anRhCw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_deleteContractor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_deleteContractor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_deleteContractor]
@contractorId uniqueidentifier
AS
BEGIN
/*Bug 1156, kuba uznał że to było zbyt restrykcyjne więc niektóre linie dostały komentarz*/
	IF @contractorId IN (
		--SELECT contractorId FROM contractor.ContractorAttrValue
		 --UNION 
		 SELECT companyContractorId FROM configuration.Configuration
		 UNION SELECT contractorId FROM contractor.ApplicationUser
		 UNION SELECT contractorId FROM contractor.Employee
		 UNION SELECT contractorId FROM contractor.ContractorRelation
		 --UNION SELECT contractorId FROM contractor.ContractorAddress
		 UNION SELECT contractorId FROM contractor.Bank
		 UNION SELECT contractorId FROM contractor.ContractorGroupMembership
		 UNION SELECT contractorGroupId FROM contractor.ContractorGroupMembership
		 --UNION SELECT contractorId FROM contractor.ContractorAccount
		 UNION SELECT bankContractorId FROM contractor.ContractorAccount		 		 
		 UNION SELECT relatedContractorId FROM contractor.ContractorRelation
		 
		 UNION SELECT ownerContractorId FROM service.ServicedObject
		 UNION SELECT issuingPersonContractorId FROM complaint.ComplaintDecision

		 UNION SELECT contractorId FROM document.FinancialDocumentHeader
		 UNION SELECT issuingPersonContractorId FROM document.FinancialDocumentHeader
		 UNION SELECT contractorId FROM document.CommercialDocumentHeader
		 UNION SELECT receivingPersonContractorId FROM document.CommercialDocumentHeader
		 UNION SELECT issuingPersonContractorId FROM document.CommercialDocumentHeader
		 UNION SELECT issuerContractorId FROM document.CommercialDocumentHeader
		 UNION SELECT contractorAddressId FROM document.CommercialDocumentHeader
		 UNION SELECT issuerContractorAddressId FROM document.CommercialDocumentHeader
		 UNION SELECT contractorId FROM document.WarehouseDocumentHeader
		 
		 UNION SELECT issuingPersonContractorId FROM complaint.ComplaintDocumentLine
		 UNION SELECT issuerContractorId FROM complaint.ComplaintDocumentHeader
		 UNION SELECT issuerContractorAddressId FROM complaint.ComplaintDocumentHeader
		 UNION SELECT contractorId FROM complaint.ComplaintDocumentHeader
		 UNION SELECT contractorAddressId FROM complaint.ComplaintDocumentHeader

		 UNION SELECT contractorId FROM finance.Payment
		 UNION SELECT contractorAddressId FROM finance.Payment
		 UNION SELECT bankContractorId FROM dictionary.FinancialRegister
		 UNION SELECT contractorId FROM dictionary.Company )
			BEGIN
				RAISERROR ( N''Kontrahent użyty'', 16, 1 )
			END
		ELSE	
			BEGIN
				DELETE FROM contractor.ContractorAddress WHERE contractorId = @contractorId
				DELETE FROM contractor.ContractorAccount WHERE contractorId = @contractorId
				DELETE FROM contractor.ContractorDictionaryRelation WHERE contractorId = @contractorId
				DELETE  FROM contractor.ContractorDictionary
                WHERE   id NOT IN (
                        SELECT  contractorDictionaryId
                        FROM    contractor.ContractorDictionaryRelation )
				DELETE FROM contractor.ContractorAttrValue WHERE contractorId = @contractorId
				DELETE FROM contractor.COntractor WHERE id = @contractorId
							
			END
 
 
END
' 
END
GO
