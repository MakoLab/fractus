/*
name=[warehouse].[p_deleteShiftAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fWVGIkL9Jq3QwpFIAdwv1Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_deleteShiftAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_deleteShiftAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_deleteShiftAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_deleteShiftAttrValue] @xmlVar XML
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT


    /*Kasowanie danych o Shiftach*/
    DELETE FROM warehouse.ShiftAttrValue
    WHERE   id IN (
            SELECT  NULLIF(con.value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/*/entry/id'') AS C ( con )
             )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:ShiftAttrValue; error:'' + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO
