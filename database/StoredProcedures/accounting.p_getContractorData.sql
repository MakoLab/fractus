/*
name=[accounting].[p_getContractorData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
z8k7Po7YLLDYxCktzU7K6Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getContractorData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getContractorData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getContractorData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getContractorData] 
    @contractorId UNIQUEIDENTIFIER
AS 
BEGIN


DECLARE 
@contractorAddres XML


IF NOT EXISTS (SELECT * FROM contractor.Contractor c WHERE c.id = @contractorId )
BEGIN
  RAISERROR ( ''Brak kontrahenta'', 16, 1 )
  RETURN 0
END

SELECT @contractorAddres = ISNULL(
	(
		SELECT    
			ISNULL((SELECT symbol FROM dictionary.Country WHERE id = ca.countryId ),'''') country,
            ISNULL(ca.postCode,'''') postCode,
            ISNULL(ca.city,'''') city,
            '''' region,
            '''' premise,
            '''' building,
            ISNULL(ca.address,'''') street
            FROM      contractor.ContractorAddress ca
            WHERE     contractorId = @contractorId
            FOR XML PATH(''address''), TYPE 
     ), 
     ''<address>
        <countr></countr>
        <postCode></postCode>
        <city></city>
        <region></region>
        <premise></premise>
        <building></building>
        <street></street>
      </address>''
)

DECLARE @accountContractor xml
DECLARE @isSupplier bit
DECLARE @isReceiver bit
DECLARE @Supplier int
DECLARE @Receiver int
DECLARE @listAccount xml

SELECT @isSupplier=isSupplier, @isReceiver=isReceiver FROM contractor.Contractor WHERE id = @contractorId
IF (@isSupplier = 1)
	SET @Supplier = 2

IF (@isReceiver = 1)
	SET @Receiver = 1

IF ((@isSupplier = 0) AND (@isReceiver = 0) )
BEGIN
	SET @Supplier = 1
	SET @Receiver = 1
END

SET @accountContractor = (select xmlvalue from configuration.configuration where [key] = ''accounting.contractorAccounting'')

SET @listAccount = (SELECT c.con.query(''.'')
					FROM @accountContractor.nodes(''/accountingEntries/accountingEntrie'') AS c(con)
					WHERE (c.con.value(''@skmId'',''int'') = @Supplier) OR (c.con.value(''@skmId'',''int'') = @Receiver)
					FOR XML PATH(''accountingEntries''), TYPE)



SELECT 
                (SELECT newid() FOR XML PATH(''requestId''), TYPE),
                (SELECT ''exportContractor'' FOR XML PATH(''method''), TYPE ),
                (SELECT 
							   c.version version,
                               c.id foreignId,
							   (SELECT (
                                         SELECT externalId FROM accounting.ExternalMapping 
                                         WHERE id = @contractorId)
                                FOR XML PATH(''id''), TYPE),
                               (select textValue from configuration.Configuration WHERE  [key] = ''accounting.codeContractor'') codeContractor,
                               ISNULL(c.nip,'''') taxId,
                               ISNULL(c.fullName,'''') name,
                               ISNULL(c.shortName,'''') shortName,

                               CONVERT(VARCHAR(10), 
									ISNULL( (SELECT MIN(issueDate) FROM document.CommercialDocumentHeader CDH WHERE CDH.contractorId=@contractorId),
											GETDATE()), 21) dateCreate,
                               CASE WHEN c.isReceiver  = 1 AND c.isSupplier = 0 THEN 16 WHEN  c.isReceiver  = 0 AND c.isSupplier = 1 THEN 8 WHEN  c.isReceiver  = 1 AND c.isSupplier = 1 THEN 24 END   [type],
                               @contractorAddres,
                               (SELECT 
                                               ISNULL( (select TOP 1 textValue from contractor.ContractorAttrValue WHERE contractorFieldId = (select id from dictionary.ContractorField WHERE name = ''Contact_Phone'') AND contractorId = c.id ORDER BY [order]  ),'''') phone,
                                               ISNULL( (select TOP 1 textValue from contractor.ContractorAttrValue WHERE contractorFieldId = (select id from dictionary.ContractorField WHERE name = ''Contact_Fax'') AND contractorId = c.id  ORDER BY [order]  ),'''') fax,
                                               ISNULL( (select TOP 1 textValue from contractor.ContractorAttrValue WHERE contractorFieldId = (select id from dictionary.ContractorField WHERE name = ''Contact_Mobile'') AND contractorId = c.id  ORDER BY [order] ),'''')  mobile
                               FOR XML PATH(''contact''), TYPE
                                ),
                               @listAccount

                FROM      contractor.Contractor c
                WHERE     c.id = @contractorId
                FOR XML PATH(''contractor''), TYPE)
 FOR XML PATH(''request''), TYPE

END



/****** Object:  StoredProcedure [accounting].[p_getDocumentData]    Script Date: 11/19/2009 11:16:25 ******/
SET ANSI_NULLS ON



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
' 
END
GO
