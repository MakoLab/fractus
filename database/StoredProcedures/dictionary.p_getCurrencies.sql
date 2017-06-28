/*
name=[dictionary].[p_getCurrencies]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
EJi+xBUC89um6VBXZG5aZQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getCurrencies]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getCurrencies]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getCurrencies]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getCurrencies]
AS 
	/*Budowa XML z Walutami*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.Currency
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''currency''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
