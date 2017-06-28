/*
name=[document].[p_updateFinancialDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qIFcQ4JS9xuumYUk3R5EVQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateFinancialDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateFinancialDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateFinancialDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateFinancialDocumentHeader]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja nagłówka FinancialDocumentHeader*/
        UPDATE  [document].FinancialDocumentHeader
        SET     [status] = CASE WHEN con.exist(''status'') = 1
                                                  THEN con.query(''status'').value(''.'', ''int'')
                                                  ELSE NULL
                                             END,
                branchId = CASE WHEN con.exist(''branchId'') = 1
                                     THEN con.query(''branchId'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END,
                companyId = CASE WHEN con.exist(''companyId'') = 1
                              THEN con.query(''companyId'').value(''.'', ''char(36)'')
                              ELSE NULL
                         END,
                documentTypeId = CASE WHEN con.exist(''documentTypeId'') = 1
                                   THEN con.query(''documentTypeId'').value(''.'', ''char(36)'')
                                   ELSE NULL
                              END,
                contractorId = CASE WHEN con.exist(''contractorId'') = 1
                                THEN con.query(''contractorId'').value(''.'', ''char(36)'')
                                ELSE NULL
                           END,
                contractorAddressId = CASE WHEN con.exist(''contractorAddressId'') = 1
                                  THEN con.query(''contractorAddressId'').value(''.'', ''char(36)'')
                                  ELSE NULL
                             END,
                issueDate = CASE WHEN con.exist(''issueDate'') = 1
                                  THEN con.query(''issueDate'').value(''.'', ''datetime'')
                                  ELSE NULL
                             END,
                issuingPersonContractorId = CASE WHEN con.exist(''issuingPersonContractorId'') = 1
                                       THEN con.query(''issuingPersonContractorId'').value(''.'', ''char(36)'')
                                       ELSE NULL
                                  END,
                modificationDate = CASE WHEN con.exist(''modificationDate'') = 1
                                        THEN con.query(''modificationDate'').value(''.'', ''datetime'')
                                        ELSE NULL
                                   END,
                modificationApplicationUserId = CASE WHEN con.exist(''modificationApplicationUserId'') = 1
                                          THEN con.query(''modificationApplicationUserId'').value(''.'', ''char(36)'')
                                          ELSE NULL
                                     END,

                amount = CASE WHEN con.exist(''amount'') = 1
                                          THEN con.query(''amount'').value(''.'', ''numeric(18,2)'')
                                          ELSE NULL
                                     END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
				xmlConstantData = CASE WHEN con.exist(''xmlConstantData'') = 1
					 THEN con.query(''xmlConstantData/*'')
					 ELSE NULL
				END,
				financialReportId = CASE WHEN con.exist(''financialReportId'') = 1
                               THEN con.query(''financialReportId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
				documentCurrencyId = CASE WHEN con.exist(''documentCurrencyId'') = 1
                               THEN con.query(''documentCurrencyId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
				systemCurrencyId = CASE WHEN con.exist(''systemCurrencyId'') = 1
                               THEN con.query(''systemCurrencyId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/financialDocumentHeader/entry'') AS C ( con )
        WHERE   FinancialDocumentHeader.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: FinancialDocumentHeader; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO
