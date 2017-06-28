/*
name=[dictionary].[p_getEventTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MHlDSRDLCK67VXAAJSvi8A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getEventTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getEventTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getEventTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getEventTypes]
AS 
	/*Budowanie XML z typami dokumentów*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.EventType
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''eventType''),TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
