/*
name=[item].[p_getItemEquivalents]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
A+LVzbEuR8oxBZzIv4l+dQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemEquivalents]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemEquivalents]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemEquivalents]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_getItemEquivalents]
    @itemId UNIQUEIDENTIFIER = NULL,
    @groupId UNIQUEIDENTIFIER = NULL
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @returnXML XML

		/*Budowanie XML z danycmi o powiązaniach towaru*/
        SELECT  @returnXML = ( SELECT   item.id,
                                        name,
                                        code
                               FROM     item.ItemRelation itemR
                                        JOIN item.Item item ON itemR.itemId = item.id
                               WHERE    ( relatedObjectId = @groupId OR @groupId IS NULL)
                                        AND item.id <> @itemId
                             FOR
                               XML AUTO,
                                   TYPE
                             )
		/*Zwrócenie wyników*/
        SELECT  @returnXML
        FOR     XML PATH(''root''),
                    TYPE
    END
' 
END
GO
