/*
name=[document].[p_updateInventorySheetLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
o5eBV6EaQRXY+AYY09H87g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateInventorySheetLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateInventorySheetLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateInventorySheetLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateInventorySheetLine] 
@xmlVar XML
AS 
    BEGIN

	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc INT,
			@applicationUserId UNIQUEIDENTIFIER
			
		--/*Pobranie uzytkownika aplikacji*/
  --      SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
  --      FROM    @xmlVar.nodes(''root'') AS x ( a )


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	DECLARE @tmp TABLE(
		[id] [uniqueidentifier]  NULL,
		[inventorySheetId] [uniqueidentifier]  NULL,
		[ordinalNumber] [int]  NULL,
		[itemId] [uniqueidentifier]  NULL,
		[systemQuantity] [numeric](18, 6)  NULL,
		[systemDate] [datetime]  NULL,
		[userQuantity] [numeric](18, 6) NULL,
		[userDate] [datetime] NULL,
		[description] [nvarchar](1000) NULL,
		[version] [uniqueidentifier]  NULL,
		[direction] [int]  NULL,
		[unitId] [uniqueidentifier]  NULL
	)
	INSERT INTO @tmp ([id],  [inventorySheetId],  [ordinalNumber],  [itemId],  [systemQuantity],  [systemDate],  [userQuantity],  [userDate],  [description],  [version] , [direction], [unitId])
	SELECT [id],  [inventorySheetId],  [ordinalNumber],  [itemId],  [systemQuantity],  [systemDate],  [userQuantity],  [userDate],  [description],  [version] , [direction], [unitId]
		FROM OPENXML(@idoc, ''/root/inventorySheetLine/entry'')
					WITH(
							id uniqueidentifier ''id'' ,  
							inventorySheetId uniqueidentifier ''inventorySheetId'' ,  
							ordinalNumber int ''ordinalNumber'' ,  
							itemId uniqueidentifier ''itemId'' ,  
							systemQuantity numeric(18,6) ''systemQuantity'' ,  
							systemDate datetime ''systemDate'' ,  
							userQuantity numeric(18,6) ''userQuantity'' ,  
							userDate datetime ''userDate'' ,  
							[description] nvarchar(1000) ''description'' ,  
							[direction] int ''direction'',
							[unitId] uniqueidentifier ''unitId'',
							[version] uniqueidentifier ''_version''
						)
	
	UPDATE  x
	SET
		[inventorySheetId] = ISNULL( y.inventorySheetId,x.[inventorySheetId]),
		[ordinalNumber] = ISNULL(y.[ordinalNumber] ,x.[ordinalNumber]),
		[itemId] = ISNULL(y.[itemId],x.[itemId]),
		[systemQuantity] = ISNULL(y.[systemQuantity],x.[systemQuantity]),
		[systemDate] = ISNULL(y.[systemDate],x.[systemDate]),
		[userQuantity] = ISNULL(y.[userQuantity], x.[userQuantity]),
		[userDate] = ISNULL(y.[userDate], x.[userDate]),
		[description] = ISNULL(y.[description], x.[description]),
		[version] = ISNULL(y.[version],x.[version]),
		[direction] = ISNULL(y.[direction], x.[direction]),
		[unitId] = ISNULL(y.[unitId], x.[unitId])
	FROM document.InventorySheetLine x
	JOIN @tmp y	ON x.id = y.id
				
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT				
    
	EXEC sp_xml_removedocument @idoc

	        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:InventorySheetLine; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
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
