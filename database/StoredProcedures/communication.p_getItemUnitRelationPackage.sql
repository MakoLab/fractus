/*
name=[communication].[p_getItemUnitRelationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JuoUdOzMcrA2aa0uFvAIUg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getItemUnitRelationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getItemUnitRelationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getItemUnitRelationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getItemUnitRelationPackage] @id UNIQUEIDENTIFIER
AS /*Gets ItemUnitRelationPackage that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        /*Budowa obrazu danych*/
        SELECT  @result = ( 
						SELECT (
							SELECT  id ''id'',
                                    itemId ''itemId'',
                                    unitId ''unitId'',
                                    [precision] ''precision'',
                                    version ''version''
                            FROM    item.ItemUnitRelation
                            WHERE   ItemUnitRelation.id = @id
                            FOR XML PATH(''entry''), TYPE )
                        FOR XML PATH(''itemUnitRelation''), TYPE
                        )
		/*Zwrócenie wyników*/
        SELECT  @result
        FOR     XML PATH(''root''), TYPE
    END
' 
END
GO
