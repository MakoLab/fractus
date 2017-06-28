/*
name=[warehouse].[p_getShiftForWarehouseDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CVSO1zSxCGB+JkQiGQKWVw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftForWarehouseDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShiftForWarehouseDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftForWarehouseDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getShiftForWarehouseDocument]
@warehouseDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN


		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( 
											SELECT    ST.*
											FROM warehouse.ShiftTransaction ST
											WHERE ST.id IN (
														SELECT shiftTransactionId 
														FROM  warehouse.Shift s 
															JOIN document.WarehouseDocumentLine l ON s.warehouseDocumentLineId = l.id
														WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND s.status >= 0
														)
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''shiftTransaction''), TYPE
                            ),
                            ( SELECT    ( SELECT    S.*, ISNULL(S.containerId , ( SELECT containerId FROM warehouse.Shift WHERE id = S.sourceShiftId ) ) sourceContainerId
                                          FROM      warehouse.Shift S
											JOIN warehouse.ShiftTransaction st ON s.shiftTransactionId = st.id
											JOIN document.WarehouseDocumentLine l ON S.warehouseDocumentLineId = l.id
                                          WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND s.[status] > 0
										  ORDER BY l.incomeDate, st.issueDate
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''shift''), TYPE
                            ),
                            ( SELECT    ( SELECT    CS.*
                                          FROM      warehouse.ContainerShift CS
                                          WHERE     CS.shiftTransactionId  IN (
														SELECT shiftTransactionId 
														FROM  warehouse.Shift s 
															JOIN document.WarehouseDocumentLine l ON s.warehouseDocumentLineId = l.id
														WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND s.status >= 0
														)
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''containerShift''), TYPE
                            ),
                            ( SELECT    ( SELECT    SA.*
                                          FROM      warehouse.ShiftAttrValue SA
                                          WHERE     SA.shiftId  IN (
														SELECT s.id 
														FROM  warehouse.Shift s 
															JOIN document.WarehouseDocumentLine l ON s.warehouseDocumentLineId = l.id
														WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND s.status >= 0
														)
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''shiftAttrValue''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id IN ( SELECT  DISTINCT applicationUserId
                                                           FROM     warehouse.ShiftTransaction
                                                           WHERE    id  IN (
														SELECT shiftTransactionId 
														FROM  warehouse.Shift s 
															JOIN document.WarehouseDocumentLine l ON s.warehouseDocumentLineId = l.id
														WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId AND s.status >= 0
														)
                                                         )
	                                      FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''contractor''), TYPE
                            )
                FOR XML PATH(''root''), TYPE
                ) AS returnsXML
    END
' 
END
GO
