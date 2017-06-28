/*
name=[document].[p_checkFinancialReportVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
W9f4K/6ucWH1OarkXVclOw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkFinancialReportVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkFinancialReportVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkFinancialReportVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkFinancialReportVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    finance.FinancialReport
                        WHERE   FinancialReport.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
