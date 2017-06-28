/*
name=[communication].[p_getCommercialWarehouseRelationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
guTVvz6EqxEETNVV7v3MhA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getCommercialWarehouseRelationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getCommercialWarehouseRelationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getCommercialWarehouseRelationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getCommercialWarehouseRelationPackage]
@id UNIQUEIDENTIFIER
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
												isValuated ''isValuated'',
												isOrderRelation ''isOrderRelation'',
												isCommercialRelation ''isCommercialRelation'',
												isServiceRelation ''isServiceRelation'',
												version ''version''
                                      FROM      document.CommercialWarehouseRelation i 
									  WHERE		i.id = @id
	                                  FOR XML PATH(''entry''), TYPE
										)
                                    FOR XML PATH(''commercialWarehouseRelation''), TYPE
                                    )
                        FOR XML PATH(''root''), TYPE
                        )  
		SELECT @snap

    END
' 
END
GO
