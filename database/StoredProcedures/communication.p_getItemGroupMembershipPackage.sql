/*
name=[communication].[p_getItemGroupMembershipPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4OcdZ9M4tqYQs1I4Vg5dhA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getItemGroupMembershipPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getItemGroupMembershipPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getItemGroupMembershipPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getItemGroupMembershipPackage] @id UNIQUEIDENTIFIER
AS /*Gets ItemGroupMembership xml Package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @snap XML
		/*Budowa obrazu danych*/
        SELECT  @snap = ( 
						SELECT (
						  SELECT    @id ''id'',
                                    itemId ''itemId'',
                                    itemGroupId ''itemGroupId'',
                                    version ''version''
                          FROM      item.ItemGroupMembership
                          WHERE     ItemGroupMembership.id = @id
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
