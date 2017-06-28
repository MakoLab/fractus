/*
name=[service].[p_checkServicedObjectVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KXGt7DPy8lnVNp58QwCCGQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_checkServicedObjectVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_checkServicedObjectVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_checkServicedObjectVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_checkServicedObjectVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    service.ServicedObject
                        WHERE   ServicedObject.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
