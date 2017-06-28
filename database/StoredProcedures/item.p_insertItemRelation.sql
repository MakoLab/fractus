/*
name=[item].[p_insertItemRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dIdaPsUL8YErJP29TjvoCQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItemRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_insertItemRelation]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@error int 
 BEGIN   
	BEGIN TRY

    /*Wstawienie danych o powiązaniach towarów*/
    INSERT  INTO [item].[ItemRelation]
            (
              id,
              itemId,
              relatedObjectId,
              itemRelationTypeId,
              version,
              [order],
              relatedObjectOrder 
            )
            SELECT  NULLIF(con.value(''(id)[1]'', ''char(36)''), ''''),
                    NULLIF(con.value(''(itemId)[1]'', ''char(36)''), ''''),
                    NULLIF(con.value(''(relatedObjectId)[1]'', ''char(36)''),''''),
                    NULLIF(con.value(''(itemRelationTypeId)[1]'', ''char(36)''), ''''),
                    ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)'')),
                    NULLIF(con.value(''(order)[1]'', ''int''), ''''),
                    NULLIF(con.value(''(relatedObjectOrder)[1]'', ''int''),'''')
            FROM    @xmlVar.nodes(''/root/itemRelation/entry'') AS C ( con )
			WHERE con.value(''(id)[1]'', ''char(36)'') NOT IN (SELECT id FROM [item].[ItemRelation])
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
			EXEC [item].[p_updateItemRelation] @xmlVar
		END
	ELSE IF @rowcount = 0
			BEGIN
				RAISERROR ( 50011, 16, 1 ) ;
			END
    END
' 
END
GO
