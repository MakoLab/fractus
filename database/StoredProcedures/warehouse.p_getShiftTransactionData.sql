/*
name=[warehouse].[p_getShiftTransactionData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
c90aU0wghY5en61/TrU29g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftTransactionData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShiftTransactionData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftTransactionData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getShiftTransactionData]
@shiftTransactionId UNIQUEIDENTIFIER
AS
BEGIN

		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( 
											SELECT    ST.*
											FROM warehouse.ShiftTransaction ST
											WHERE ST.id = @shiftTransactionId
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''shiftTransaction''), TYPE
                            ),
                            ( SELECT    ( SELECT    S.*
                                          FROM      warehouse.Shift S
                                          WHERE     S.shiftTransactionId = @shiftTransactionId AND S.status >= 0
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''shift''), TYPE
                            ),
                            ( SELECT    ( SELECT    CS.*
                                          FROM      warehouse.ContainerShift CS
                                          WHERE     CS.shiftTransactionId = @shiftTransactionId
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''containerShift''), TYPE
                            ),
                            ( SELECT    ( SELECT    SA.*
                                          FROM      warehouse.ShiftAttrValue SA
                                          WHERE     SA.shiftId  IN (
														SELECT s.id 
														FROM  warehouse.Shift s 
														WHERE s.shiftTransactionId = @shiftTransactionId AND s.status >= 0
														)
	                                      FOR XML PATH(''entry''),TYPE
                                        )
                            FOR XML PATH(''shiftAttrValue''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id = ( SELECT   applicationUserId
                                                           FROM     warehouse.ShiftTransaction
                                                           WHERE    id = @shiftTransactionId
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
