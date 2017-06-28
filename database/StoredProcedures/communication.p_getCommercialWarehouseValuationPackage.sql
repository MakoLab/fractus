/*
name=[communication].[p_getCommercialWarehouseValuationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
V8juSnmfeWYTbl5wf+E2ew==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getCommercialWarehouseValuationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getCommercialWarehouseValuationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getCommercialWarehouseValuationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getCommercialWarehouseValuationPackage] @id UNIQUEIDENTIFIER
AS
    BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML

		/*Budowa obrazu danych*/
        SELECT  @snap = ( SELECT    
							( SELECT
									( SELECT    @id ''id'',
                                                commercialDocumentLineId ''commercialDocumentLineId'',
                                                warehouseDocumentLineId ''warehouseDocumentLineId'',
                                                quantity ''quantity'',
												[value] ''value'',
												price ''price'', 
												version ''version''
                                      FROM      document.CommercialWarehouseValuation i 
									  WHERE		i.id = @id
									  FOR XML PATH(''entry''), TYPE
                                      )
                                 FOR XML PATH(''commercialWarehouseValuation''), TYPE
                                 )
                        FOR XML PATH(''root''), TYPE
                        )  
		SELECT @snap
    END
' 
END
GO
