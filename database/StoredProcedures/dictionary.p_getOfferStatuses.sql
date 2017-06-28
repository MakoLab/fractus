/*
name=[dictionary].[p_getOfferStatuses]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lnJyhMotEp1bZQjAOP/iJg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getOfferStatuses]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getOfferStatuses]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getOfferStatuses]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getOfferStatuses]
AS 
	/*Budowanie XML z statusami ofert*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.OfferStatus
                                      ORDER BY  [value]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''offerStatus''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
