/*
name=[communication].[p_getItemRelationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Xf4rEJJNFiyXT0VVFQ7haQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getItemRelationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getItemRelationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getItemRelationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getItemRelationPackage] @id UNIQUEIDENTIFIER
/*Gets ItemRelation xml package that match input parameter*/
AS 
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        /*Budowa obrazu danych*/
        SELECT  @result = ( 
						SELECT (
							SELECT  id ''id'',
                                    itemId ''itemId'',
                                    itemRelationTypeId ''itemRelationTypeId'',
                                    relatedObjectId ''relatedObjectId'',
                                    version ''version''
                            FROM    item.ItemRelation
                            WHERE   ItemRelation.id = @id
                          FOR XML PATH(''entry''), TYPE )
                          FOR XML PATH(''itemRelation''), TYPE
                          )
		/*Zwrócenie wyniku*/
        SELECT  @result
        FOR     XML PATH(''root''), TYPE
    END
' 
END
GO
