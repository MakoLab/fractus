/*
name=[warehouse].[p_handheld_setAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
E5x3gPi08hWopU5mrW5EUg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_setAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_setAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_setAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_setAttrValue]
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@attrV decimal(18,6),
			@attrA decimal(18,6),
			@attrT datetime,
			@attrB uniqueidentifier,
			@shiftId uniqueidentifier
			
			
--<root>
--	<attribute_Voltage></attribute_Voltage>
--	<attribute_Current></attribute_Current>
--	<attribute_MeasureTime></attribute_MeasureTime>
--	<attribute_MeasuredBy></attribute_MeasuredBy>
--</root>
			
	/*Procka do obsługi wstawiania lub aktualizacji wartości atrybutów shiftów*/		
	BEGIN TRAN
				
	SELECT 
		@attrV = NULLIF(x.query(''attribute_Voltage'').value(''.'', ''varchar(50)''),''''),
		@attrA = NULLIF(x.query(''attribute_Current'').value(''.'', ''varchar(50)''),''''),
		@attrB = NULLIF(x.query(''attribute_MeasuredBy'').value(''.'', ''char(36)''),''''),
		@attrT = NULLIF(x.query(''attribute_MeasureTime'').value(''.'', ''datetime''),''''),
		@shiftId = NULLIF(x.query(''shiftId'').value(''.'', ''char(36)''),'''')
	FROM @xmlVar.nodes(''root'') as a(x)
	
	IF EXISTS (SELECT id FROM warehouse.ShiftAttrValue WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_Voltage'') )
		UPDATE warehouse.ShiftAttrValue 
			SET decimalValue = @attrV
		WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_Voltage'') 	
	ELSE
		INSERT INTO warehouse.ShiftAttrValue ([id],  [shiftId],  [shiftFieldId],  [decimalValue],  [version])  
		SELECT newid(),  @shiftId, (SELECT	id FROM dictionary.ShiftField WHERE name = ''Attribute_Voltage''),  @attrV,  newid()
		WHERE @attrV IS NOT NULL

    IF @@error <> 0 
        BEGIN
			ROLLBACK TRAN
            SET @errorMsg = ''Błąd wstawiania danych atrybutu:Attribute_Voltage tabela:ShiftAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            
            RAISERROR ( @errorMsg, 16, 1 )
        END		
	
	IF EXISTS (SELECT id FROM warehouse.ShiftAttrValue WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_Current'') )
		UPDATE warehouse.ShiftAttrValue 
			SET decimalValue = @attrA
		WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_Current'')
	ELSE
		INSERT INTO warehouse.ShiftAttrValue ([id],  [shiftId],  [shiftFieldId],  [decimalValue],  [version])  
		SELECT newid(),  @shiftId, (SELECT	id FROM dictionary.ShiftField WHERE name = ''Attribute_Current''),  @attrA,  newid()
		WHERE @attrA IS NOT NULL
		
    IF @@error <> 0 
        BEGIN
			ROLLBACK TRAN
            SET @errorMsg = ''Błąd wstawiania danych atrybutu:Attribute_Current tabela:ShiftAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            
            RAISERROR ( @errorMsg, 16, 1 )
        END			
		
	IF EXISTS (SELECT id FROM warehouse.ShiftAttrValue WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_MeasureTime'') )
		UPDATE warehouse.ShiftAttrValue 
			SET dateValue = @attrT
		WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_MeasureTime'')
	ELSE
		INSERT INTO warehouse.ShiftAttrValue ([id],  [shiftId],  [shiftFieldId],  [dateValue],  [version])  
		SELECT newid(),  @shiftId, (SELECT	id FROM dictionary.ShiftField WHERE name = ''Attribute_MeasureTime''),  @attrT,  newid()
		WHERE @attrT IS NOT NULL

    IF @@error <> 0 
        BEGIN
			ROLLBACK TRAN
            SET @errorMsg = ''Błąd wstawiania danych atrybutu:Attribute_MeasureTime tabela:ShiftAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            
            RAISERROR ( @errorMsg, 16, 1 )
        END	
		
	IF EXISTS (SELECT id FROM warehouse.ShiftAttrValue WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_MeasuredBy'') )
		UPDATE warehouse.ShiftAttrValue 
			SET textValue = @attrB
		WHERE shiftId = @shiftId AND [shiftFieldId] = (SELECT id FROM dictionary.ShiftField WHERE name = ''Attribute_MeasuredBy'')
	ELSE
		INSERT INTO warehouse.ShiftAttrValue ([id],  [shiftId],  [shiftFieldId],  textValue,  [version])  
		SELECT newid(),  @shiftId, (SELECT	id FROM dictionary.ShiftField WHERE name = ''Attribute_MeasuredBy''),  @attrB,  newid()
		WHERE @attrB IS NOT NULL
	
    IF @@error <> 0 
        BEGIN
			ROLLBACK TRAN
            SET @errorMsg = ''Błąd wstawiania danych atrybutu:Attribute_MeasuredBy tabela:ShiftAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            
            RAISERROR ( @errorMsg, 16, 1 )
        END	
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
			ROLLBACK TRAN
            SET @errorMsg = ''Błąd wstawiania danych table:ShiftAttrValue; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            COMMIT TRAN
        END

END
' 
END
GO
