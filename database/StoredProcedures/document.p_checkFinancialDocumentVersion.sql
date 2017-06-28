/*
name=[document].[p_checkFinancialDocumentVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nehgk4BWsM6hqokZAVQuwg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkFinancialDocumentVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkFinancialDocumentVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkFinancialDocumentVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkFinancialDocumentVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    [document].FinancialDocumentHeader
                        WHERE   FinancialDocumentHeader.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
