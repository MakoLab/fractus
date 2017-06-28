/*
name=[custom].[p_updateOrbisIntegrationFilteredEntry]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KwWu+OIiZsayQFTmwNFhKA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_updateOrbisIntegrationFilteredEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_updateOrbisIntegrationFilteredEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_updateOrbisIntegrationFilteredEntry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_updateOrbisIntegrationFilteredEntry] @dueDays int = null, @nip varchar(50) = null
AS
BEGIN
	BEGIN TRY

		TRUNCATE TABLE custom.OrbisIntegrationFiltered

		INSERT INTO custom.OrbisIntegrationFiltered( id, contractorName, contractorAddress, contractorNip, contractorEmail, documentNumber, grossValue, issueDate, dueDate, isSettled, documentPrintPdfUrl, contractorData)


		SELECT h.id, 
			   ISNULL(h.xmlConstantData.value(''(//constant/contractor/fullName)[1]'',''varchar(500)''), c.fullName) ,
			   ISNULL(h.xmlConstantData.value(''(//constant/contractor/addresses/address/address)[1]'',''varchar(500)'') ,'''') + '' '' +char(10) +
			   ISNULL(h.xmlConstantData.value(''(//constant/contractor/addresses/address/postCode)[1]'',''varchar(500)''),'''') + '' '' +
			   ISNULL(h.xmlConstantData.value(''(//constant/contractor/addresses/address/city)[1]'',''varchar(500)''),'''') ,
			   h.xmlConstantData.value(''(//constant/contractor/nip)[1]'',''varchar(500)''),
			   (SELECT top 1 av.textValue FROM contractor.ContractorAttrValue av  WITH(NOLOCK) WHERE av.contractorId = c.id AND av.contractorFieldId = (SELECT id FROM dictionary.ContractorField  WITH(NOLOCK) WHERE name = ''Contact_Email'') ),
			   h.fullNumber,
			   h.grossValue,
			   h.issueDate,
			   (SELECT max(p.duedate) FROM finance.Payment p  WITH(NOLOCK) WHERE p.commercialDocumentHeaderId = h.id) dueDate,
			   (SELECT MIN(CASE WHEN unsettledAmount = 0 OR requireSettlement = 0 THEN 1 ELSE 0 END) FROM finance.Payment p  WITH(NOLOCK) WHERE p.commercialDocumentHeaderId = h.id) isSettled,
			   ''http://localhost'' + CAST(h.id as char(36)) + ''/defaultSalesDocumentPdf/'' + dt.symbol + ''_'' + REPLACE(h.fullNumber ,''/'',''_'' ) + ''?'',
			   (SELECT xmlValue FROM [contractor].[v_contractorExportData] WITH(NOLOCK) WHERE id = c.id) contractorData
		FROM document.CommercialDocumentHeader h WITH(NOLOCK)
			JOIN dictionary.DocumentType dt WITH(NOLOCK) ON h.documentTypeId = dt.id
			LEFT JOIN contractor.Contractor c WITH(NOLOCK) ON h.contractorId = c.id 
		WHERE ( @nip IS NULL OR c.strippedNip = @nip )
			AND DATEDIFF(dd,(SELECT max(p.duedate) FROM finance.Payment p  WITH(NOLOCK) WHERE p.commercialDocumentHeaderId = h.id), GETDATE()) + @dueDays > 0
			
	END TRY
	BEGIN CATCH
	PRINT '' '' 
	END CATCH

END
' 
END
GO
