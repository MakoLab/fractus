/*
name=[communication].[p_getWarehouseDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
94wCQMCsztJlQb1YvrYQ9Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getWarehouseDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getWarehouseDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getWarehouseDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getWarehouseDocumentPackage] @id UNIQUEIDENTIFIER
AS /*Gets warehouseDocument xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
		/*Budowanie obrazu danych*/
        SELECT  @result = ( SELECT  ( SELECT    ( SELECT    *
                                                  FROM      document.WarehouseDocumentHeader
                                                  WHERE     id = @id
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''warehouseDocumentHeader''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      document.WarehouseDocumentLine
                                                  WHERE     warehouseDocumentHeaderId = @id
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''warehouseDocumentLine''),
                                          TYPE
                                    ),
									( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     warehouseDocumentHeaderId = @id
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
									FOR
									  XML PATH(''documentAttrValue''),
										  TYPE
									),
                                    ( SELECT    ( SELECT    *
                                                  FROM      document.WarehouseDocumentValuation
                                                  WHERE     incomeWarehouseDocumentLineId IN (SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @id)
														OR  outcomeWarehouseDocumentLineId IN (SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @id)
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''warehouseDocumentValuation''),
                                          TYPE
                                    )
                          FOR
                            XML PATH(''root''),
                                TYPE
                          )
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
