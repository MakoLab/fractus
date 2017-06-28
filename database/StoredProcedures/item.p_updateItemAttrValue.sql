/*
name=[item].[p_updateItemAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
DPLDHPmcEDecixkRJ8UaUg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_updateItemAttrValue]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
				@rowcount INT

        DECLARE @tmp TABLE (id uniqueidentifier, itemId uniqueidentifier, itemFieldId uniqueidentifier, decimalValue decimal (18,4), dateValue datetime , textValue nvarchar(500), xmlValue xml, [version] uniqueidentifier, [order] int )

		INSERT INTO @tmp
		SELECT  con.value(''(id)[1]'', ''char(36)''),
				con.value(''(itemId)[1]'',''varchar(50)''),
				con.value(''(itemFieldId)[1]'', ''char(36)''),
				con.value(''(decimalValue)[1]'', ''decimal(18,4)''),
				con.value(''(dateValue)[1]'', ''datetime''),
				con.value(''(textValue)[1]'', ''nvarchar(500)''),
				con.query(''xmlValue/*''),
				con.value(''(_version)[1]'', ''char(36)''),
				con.value(''(order)[1]'', ''int'')
		FROM @xmlVar.nodes(''/root/itemAttrValue/entry'') AS C ( con )


        /*Aktualizacja danych*/
        UPDATE  x 
        SET     x.itemId = t.itemId,
                x.itemFieldId = t.itemFieldId,
                x.decimalValue = t.decimalValue,
                x.dateValue = t.dateValue,
                x.textValue = t.textValue,
                x.xmlValue = t.xmlValue,
                x.[version] = t.[version],
                x.[order] = t.[order]
        FROM  item.ItemAttrValue x
			JOIN @tmp t ON x.id = t.id

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table:ItemAttrValue; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO
