/*
name=[communication].[p_getFinancialReportPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VuVvhxgav25Kzh1AWcpOoA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getFinancialReportPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getFinancialReportPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getFinancialReportPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getFinancialReportPackage] @id UNIQUEIDENTIFIER
AS /*Gets item xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
		/*Tworzenie obrazu danych*/
        SELECT  @result = (         
						
							( 

							SELECT  ( SELECT    ( SELECT    CDL.*
                                          FROM      finance.FinancialReport CDL 
                                          WHERE     CDL.id = @id
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''financialReport''),TYPE
                            )
                FOR XML PATH(''root''),TYPE
                ) )

        /*Zwrócenie wyników*/                  
        SELECT  @result 
        /*Obsługa pustego resulta*/
        IF @@rowcount = 0 
            SELECT  ''''
            FOR     XML PATH(''root''),
                        TYPE
    END
' 
END
GO
