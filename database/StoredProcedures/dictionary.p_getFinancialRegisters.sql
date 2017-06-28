/*
name=[dictionary].[p_getFinancialRegisters]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ABipiDr8lQxq2MW3pT0aUw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getFinancialRegisters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getFinancialRegisters]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getFinancialRegisters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create PROCEDURE [dictionary].[p_getFinancialRegisters]
AS 
	/*Budowanie XML z rejstrami finansowymi*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.FinancialRegister
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''financialRegister''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
