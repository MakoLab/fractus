/*
name=[custom].[p_insertOrbisIntegrationEntry]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
pqgzmu7y5XV2ojajY6gKxA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_insertOrbisIntegrationEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_insertOrbisIntegrationEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_insertOrbisIntegrationEntry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_insertOrbisIntegrationEntry] @id uniqueidentifier = null
AS
BEGIN
	BEGIN TRY
		INSERT INTO custom.OrbisIntegration( id, contractorName, contractorAddress, contractorNip, contractorEmail, documentNumber, grossValue, issueDate, dueDate, isSettled, documentPrintPdfUrl, contractorData)
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
			JOIN contractor.Contractor c WITH(NOLOCK) ON h.contractorId = c.id 
		WHERE ( h.id =  @id OR @id IS NULL)
			AND CAST(h.issueDate as [date]) = CAST(GETDATE() as [date])
			AND h.id not in ( SELECT id FROM custom.OrbisIntegration WITH(NOLOCK) )
			
		UPDATE x
		SET x.isSettled = (SELECT MIN(CASE WHEN unsettledAmount = 0 OR requireSettlement = 0 THEN 1 ELSE 0 END) FROM finance.Payment p  WITH(NOLOCK) WHERE p.commercialDocumentHeaderId = h.id)
		FROM custom.OrbisIntegration x 
			JOIN document.CommercialDocumentHeader h ON x.id = h.id

	END TRY
	BEGIN CATCH
	PRINT '' '' 
	END CATCH

END

IF NOT EXISTS(SELECT * FROM sys.objects where name = ''OrbisIntegrationFiltered'')
CREATE TABLE custom.OrbisIntegrationFiltered ( [id] uniqueidentifier,contractorName nvarchar(300), contractorAddress nvarchar(500), contractorNip varchar(50),contractorEmail varchar(100), 
documentNumber varchar(50), grossValue numeric(18,2), issueDate datetime, dueDate datetime, isSettled bit, documentPrintPdfUrl varchar(255), contractorData xml )
' 
END
GO
