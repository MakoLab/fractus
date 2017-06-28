/*
name=[finance].[p_getFinancialReportData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UCKfLpL96zhaAToEcKv1Kg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getFinancialReportData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [finance].[p_getFinancialReportData]
    @financialReportId UNIQUEIDENTIFIER
AS 
    BEGIN
    
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId],
											ISNULL((SELECT SUM(p.amount) 
											 FROM document.FinancialDocumentHeader h 
												LEFT JOIN finance.Payment p ON h.id = p.financialDocumentHeaderId 
											WHERE h.financialReportId = CDL.id AND p.direction = -1	),0) outcomeAmount,
											ISNULL((SELECT SUM(p.amount)
											 FROM document.FinancialDocumentHeader h 
												LEFT JOIN finance.Payment p ON h.id = p.financialDocumentHeaderId 
											WHERE h.financialReportId = CDL.id AND p.direction = 1	), 0) incomeAmount

                                          FROM      finance.FinancialReport CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @financialReportId
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''financialReport''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id = ( SELECT   creatingApplicationUserId
                                                           FROM     finance.FinancialReport
                                                           WHERE    id = @financialReportId
                                                         )
													OR id = ( SELECT   closingApplicationUserId
                                                           FROM     finance.FinancialReport
                                                           WHERE    id = @financialReportId
                                                         )
													OR id = ( SELECT   openingApplicationUserId
                                                           FROM     finance.FinancialReport
                                                           WHERE    id = @financialReportId
                                                         )
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''contractor''), TYPE
                            )
                FOR XML PATH(''root''), TYPE
                ) AS returnsXML
    END
' 
END
GO
