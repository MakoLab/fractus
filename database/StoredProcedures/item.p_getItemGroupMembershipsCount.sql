/*
name=[item].[p_getItemGroupMembershipsCount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
U5VeCqAUN3AN95O8GFfCuw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemGroupMembershipsCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemGroupMembershipsCount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemGroupMembershipsCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemGroupMembershipsCount]
    @itemGroupId UNIQUEIDENTIFIER
AS 
	/*Deklaracja zmiennych*/
    DECLARE @count INT
	
	/*Pobranie liczby kontrahentów w grupie*/
    SELECT  @count = COUNT(id)
    FROM    item.ItemGroupMembership
    WHERE   [itemGroupId] = @itemGroupId
	
	/*Zwrócenie wyników*/
    SELECT  ( SELECT    ISNULL(@count, 0)
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnXML
' 
END
GO
