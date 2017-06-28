/*
name=[item].[p_getItemEquivalentsXML]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CSblN+yhiKEahiv6e1m3+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemEquivalentsXML]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemEquivalentsXML]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemEquivalentsXML]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_getItemEquivalentsXML] @xmlVar XML
AS 
	DECLARE 
		@itemId UNIQUEIDENTIFIER 

    BEGIN
		SELECT @itemId = @xmlVar.value(''(root)[1]'',''char(36)'')
		/*Deklaracja zmiennych*/
        DECLARE @returnXML XML

		/*Budowanie XML z danycmi o powiązaniach towaru*/
        SELECT  @returnXML = ( SELECT   item.id,
                                        name,
                                        code
                               FROM     item.ItemRelation itemR
                                        JOIN item.Item item ON itemR.relatedObjectId = item.id
                               WHERE     itemR.itemId = @itemId
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
