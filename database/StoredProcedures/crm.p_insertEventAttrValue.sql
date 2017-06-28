/*
name=[crm].[p_insertEventAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
3dQ7icMFEDRcj7HRX0tbLw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertEventAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_insertEventAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertEventAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [crm].[p_insertEventAttrValue] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
      
	INSERT INTO crm.EventAttrValue ([id],  [EventId],  [eventFieldId],  [decimalValue],  [dateValue],  [textValue],  [xmlValue],  [version],  [order])   
	SELECT [id],  [EventId],  [eventFieldId],  [decimalValue],  [dateValue],  [textValue],  [xmlValue],  [version],  [order] 
	FROM OPENXML(@idoc, ''/root/EventAttrValue/entry'')
				WITH(
				[id] char(36) ''id'', 
				[EventId] char(36) ''EventId'', 
				[eventFieldId] char(36) ''eventFieldId'', 
				[decimalValue] decimal(18,9) ''decimalValue'', 
				[dateValue] datetime ''dateValue'', 
				[textValue] nvarchar(4000) ''textValue'', 
				[xmlValue] varchar(max) ''xmlValue'', 
				[version] char(36) ''version'', 
				[order] int ''order''
			)
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
 	EXEC sp_xml_removedocument @idoc
 	   
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:EventAttrValue ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
END
' 
END
GO
