/*
name=[warehouse].[p_duplicateShiftAttributes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
XygBqvLi/pAxKbvbAtMADw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_duplicateShiftAttributes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_duplicateShiftAttributes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_duplicateShiftAttributes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_duplicateShiftAttributes]    
@xmlVar XML
AS 

	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@shiftTransactionId CHAR(36)

	/*Wstawienie danych o seriach dokumentów*/
    SELECT  @shiftTransactionId = con.query(''shiftTransactionId'').value(''.'', ''char(36)'')
    FROM    @xmlVar.nodes(''/root'') AS C ( con )

	INSERT INTO warehouse.ShiftAttrValue (id, shiftId, shiftFieldId, decimalValue, textValue, xmlValue, version, dateValue )
	SELECT newid(), s.id, shiftFieldId, decimalValue, textValue, xmlValue, newid(), dateValue 
	FROM warehouse.Shift s 
		JOIN warehouse.Shift s_ ON s.sourceShiftId = s_.id
		JOIN warehouse.ShiftAttrValue sav ON s_.id = sav.shiftId
	WHERE s.shiftTransactionId = @shiftTransactionId

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    --/*Obsługa błędów i wyjątków*/
    --IF @@ERROR <> 0 
    --    BEGIN

    --        SET @errorMsg = ''Błąd wstawiania danych table:ShiftAttributes; error:''
    --            + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
    --        RAISERROR ( @errorMsg, 16, 1 )
    --    END
    --ELSE 
    --    BEGIN

    --        IF @rowcount = 0 
    --            RAISERROR ( 50011, 16, 1 ) ;
    --    END
' 
END
GO
