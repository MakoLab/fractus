/*
name=[translation].[p_getItemGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fVFXh+ANkjgoaS0EWEQhMw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_getItemGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_getItemGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_getItemGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_getItemGroupMembership] @itemId UNIQUEIDENTIFIER
AS /*Gets ItemGroupMembership xml Package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @snap XML
		/*Budowa obrazu danych*/
        SELECT  @snap = ( 
						SELECT (
						  SELECT    id ''id'',
                                    @itemId ''itemId'',
                                    itemGroupId ''itemGroupId'',
                                    version ''version''
                          FROM      item.ItemGroupMembership
                          WHERE     ItemGroupMembership.itemId = @itemId
                        FOR  XML PATH(''entry''),  TYPE )
                   FOR  XML PATH(''itemGroupMembership''),  TYPE
                   ) 
		/*Zwrócenie wyników*/
        SELECT  @snap
        FOR     XML PATH(''root''),
                    TYPE
    END
' 
END
GO
