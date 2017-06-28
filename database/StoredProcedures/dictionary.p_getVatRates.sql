/*
name=[dictionary].[p_getVatRates]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
x802a2pSRJjgEckkD5HZxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getVatRates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getVatRates]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getVatRates]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getVatRates]
AS 
	/*Budowanie XML z stawkami vat*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.VatRate
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''vatRate''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
