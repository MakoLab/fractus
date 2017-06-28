/*
name=[document].[p_checkCommercialDocumentVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DsQUDFyqpvboVxT+cFJqug==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkCommercialDocumentVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkCommercialDocumentVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkCommercialDocumentVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkCommercialDocumentVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    [document].CommercialDocumentHeader
                        WHERE   CommercialDocumentHeader.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO