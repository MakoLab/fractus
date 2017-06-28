/*
name=[item].[p_updateItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JiJuSHn1ATyCG2HVxL7UzQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_updateItem]
@xmlVar XML
AS
BEGIN
  
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@userId char(36),
			@error int 
    
	BEGIN TRY
        

    
		SELECT @userId = @xmlVar.value(''(root/@applicationUserId)[1]'',''char(36)'')


        DECLARE @tmp TABLE (id uniqueidentifier, code varchar(50), itemTypeId uniqueidentifier, name nvarchar(200), defaultPrice decimal(16,2), unitId uniqueidentifier, [version] uniqueidentifier, vatRateId uniqueidentifier,  creationDate datetime, modificationDate datetime, modificationUserId uniqueidentifier, visible bit)
		
		INSERT INTO @tmp (id, code, itemTypeId, name,defaultPrice,unitId, [version], vatRateId,creationDate,modificationDate,modificationUserId, visible)
        SELECT  con.value(''(id)[1]'', ''char(36)''), 
                con.value(''(code)[1]'', ''varchar(50)''), 
                con.value(''(itemTypeId)[1]'', ''char(36)''), 
                con.value(''(name)[1]'', ''varchar(200)''), 
                con.value(''(defaultPrice)[1]'', ''varchar(50)''),
                con.value(''(unitId)[1]'', ''char(36)''), 
                ISNULL(con.value(''(_version)[1]'', ''char(36)''),  con.value(''(version)[1]'', ''char(36)'')),
				con.value(''(vatRateId)[1]'', ''char(36)''), 
			    con.value(''(creationDate)[1]'', ''varchar(50)''), 
                con.value(''(modificationDate)[1]'', ''varchar(50)''), 
				con.value(''(modificationUserId)[1]'', ''varchar(50)''), 
				ISNULL(con.value(''(visible)[1]'', ''bit''),  1)
        FROM    @xmlVar.nodes(''/root/item/entry'') AS C ( con )

		IF EXISTS( SELECT t.id FROM @tmp t JOIN item.Item i ON t.id = i.id WHERE t.unitId <> i.unitId)
			BEGIN
		
				UPDATE ws SET ws.unitId = t.unitId
				FROM document.WarehouseStock ws 
					JOIN @tmp t ON ws.itemId = t.id 
			END


        /*Aktualizacja danych o towarze*/
        UPDATE  i
        SET     code = t.code,
                itemTypeId = t.itemTypeId,
                name = t.name,
                defaultPrice = t.defaultPrice,
                unitId = t.unitId,
                [version] = t.[version],
                vatRateId = t.vatRateId,
                modificationDate = getdate(),
                modificationUserId = ISNULL(t.modificationUserId,@userId),
				i.visible = t.visible
        FROM  item.Item  i
			JOIN @tmp t ON t.id = i.id
                

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT

     END TRY
	 BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Configuration; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC [item].[p_insertItem] @xmlVar
		END
    END
' 
END
GO
