/*
name=[dictionary].[p_getWarehouses]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5ddtz+UB1h2Tv92v7W74Gw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getWarehouses]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getWarehouses]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getWarehouses]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getWarehouses]
AS 
	/*Budowa XML z krajami*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                symbol,
												branchId,
												isActive,
                                                xmlLabels,
												xmlMetadata,
                                                version,
												[order],
												valuationMethod,
												issuePlaceId
                                      FROM      dictionary.Warehouse
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''warehouse''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
