/*
name=[dictionary].[p_getPaymentMethods]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NUAcyyEsOtM87X144AGpaA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getPaymentMethods]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getPaymentMethods]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getPaymentMethods]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getPaymentMethods]
AS 
	/*Budowa XML z metodami płatności*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.PaymentMethod
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''paymentMethod''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
