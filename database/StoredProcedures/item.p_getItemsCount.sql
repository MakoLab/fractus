/*
name=[item].[p_getItemsCount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
H1pBEsWahASuAtTwXqKBMg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsCount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsCount]
 @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @count INT
	
	/*Pobranie liczby kontrahentów w grupie*/
    SELECT  @count = COUNT(id)
    FROM    item.Item WITH(NOLOCK)

	/*Zwrócenie wyników*/
    SELECT  ( SELECT    ISNULL(@count, 0)
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnXML
' 
END
GO
