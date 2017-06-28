/*
name=[item].[p_updateItemRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6YXOA53eJ+svUjWFHCPnwQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_updateItemRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_updateItemRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_updateItemRelation]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@error int 
    
	BEGIN TRY

        /*Aktualizacja danych o powiązaniach towarów*/
        UPDATE  item.ItemRelation
        SET     itemId =  con.value(''(itemId)[1]'',''varchar(50)'') ,
                relatedObjectId =  con.value(''(relatedObjectId)[1]'', ''char(36)'') ,
                itemRelationTypeId =  con.value(''(itemRelationTypeId)[1]'', ''char(36)'') ,
                version =  ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)'')) ,
                [order] =  con.value(''(order)[1]'', ''int'') ,
                relatedObjectOrder =  con.value(''(relatedObjectOrder)[1]'', ''int'') 
        FROM    @xmlVar.nodes(''/root/itemRelation/entry'') AS C ( con )
        WHERE   ItemRelation.id = con.value(''(id)[1]'', ''char(36)'')
              
		/*Pobranie liczby wierszy*/		
        SET @rowcount = @@ROWCOUNT
        
     END TRY
	BEGIN CATCH
			SELECT @errorMsg = ''BBd wstawiania danych tabela:ItemRelation; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 AND @@NESTLEVEL < 4  
		BEGIN
			EXEC [item].[p_insertItemRelation] @xmlVar
		END
	ELSE IF @rowcount = 0
			BEGIN
				RAISERROR ( 50011, 16, 1 ) ;
			END
    END
' 
END
GO
