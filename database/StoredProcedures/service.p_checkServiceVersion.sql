/*
name=[service].[p_checkServiceVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2LLYGXGysmng5O5vcOFgqw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_checkServiceVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_checkServiceVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_checkServiceVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_checkServiceVersion] 
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  commercialDocumentHeaderId
                        FROM    service.ServiceHeader
                        WHERE   ServiceHeader.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
