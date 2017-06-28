/*
name=[item].[p_insertItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1pLLxTtLe8b30aSMssVdrA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_insertItem]
@xmlVar XML
AS
BEGIN 

DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
        @userId char(36),
			@error int 
    
	BEGIN TRY
        
    SELECT @userId = @xmlVar.value(''(root/@applicationUserId)[1]'',''char(36)'')

    /*Wstawienie danych o towarze*/
    INSERT  INTO [item].Item
            (
              id,
              code,
              itemTypeId,
              name,
              defaultPrice,
              unitId,
              version,
			  vatRateId,
			  creationDate,
			  modificationUserId,
			  creationUserId,
			  visible
            )
        SELECT  con.value(''(id)[1]'', ''char(36)''),
                con.value(''(code)[1]'', ''varchar(50)''),
                con.value(''(itemTypeId)[1]'', ''char(36)''), 
                con.value(''(name)[1]'', ''varchar(200)''),
                con.value(''(defaultPrice)[1]'', ''varchar(50)''),
                con.value(''(unitId)[1]'', ''char(36)''), 
                ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)'')),
				con.value(''(vatRateId)[1]'', ''char(36)''),
				GETDATE(),
                con.value(''(modificationUserId)[1]'', ''char(36)''),
                ISNULL(NULLIF(con.value(''(creationUserId)[1]'', ''char(36)''),'''') , @userId),
				ISNULL(con.value(''(visible)[1]'', ''bit''),1)
        FROM    @xmlVar.nodes(''/root/item/entry'') AS C ( con )
		WHERE  con.value(''(id)[1]'', ''char(36)'') NOT IN (SELECT id FROM  [item].Item )
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
 
     END TRY
	 BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Item; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC [item].[p_updateItem] @xmlVar
		END
END
' 
END
GO
