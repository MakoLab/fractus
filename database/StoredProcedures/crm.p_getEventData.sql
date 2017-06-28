/*
name=[crm].[p_getEventData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dslN1/XH7iDyvs24zdZPWQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_getEventData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_getEventData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_getEventData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [crm].[p_getEventData] @eventId UNIQUEIDENTIFIER

AS 

    BEGIN
    
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    
        
							( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [crm].[Event] CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @eventId
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''event''), TYPE
                            ),
                           
    
                            ( SELECT    ( SELECT    *
                                          FROM      [crm].EventAttrValue
                                          WHERE     eventId = @eventId
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''eventAttrValue''), TYPE
                            )
                            
                FOR XML PATH(''root''), TYPE
                ) AS returnsXML
    END
' 
END
GO
