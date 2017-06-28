/*
name=[dictionary].[p_getAccountingRules]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
k9F91CdCvg0Rcsqz3wi4Ew==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getAccountingRules]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getAccountingRules]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getAccountingRules]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getAccountingRules]
AS 
	/*Budowanie XML z rejestrami vat*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.AccountingRule
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''accountingRule''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
