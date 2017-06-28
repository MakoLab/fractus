/*
name=[item].[p_getItemPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
92pqrIttWAnsbXKDj8s/bg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemPackage]
    @itemId UNIQUEIDENTIFIER
AS /*Gets item xml package that match input parameter*/

    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @snap XML

		/*Budowa XML z danymi i towarze*/
        SELECT  @snap = ( SELECT    ( SELECT    ( SELECT    *
                                                  FROM      item.Item
                                                  WHERE     id = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''item''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      item.ItemAttrValue
                                                  WHERE     itemId = @itemId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''itemAttrValue''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''root''),
                              TYPE
                        )
                        
                        
		/*Zwrócenie wyników*/
        SELECT  @snap
    END
' 
END
GO
