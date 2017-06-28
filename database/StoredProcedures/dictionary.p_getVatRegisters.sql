/*
name=[dictionary].[p_getVatRegisters]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wCQTgT7w8TsPzfV3KjOEtw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getVatRegisters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getVatRegisters]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getVatRegisters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getVatRegisters]
AS 
	/*Budowanie XML z rejestrami vat*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.VatRegister
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''vatRegister''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
