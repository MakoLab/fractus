/*
name=[warehouse].[p_insertContainer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KbRg9zLNDVlW3TAq/VK0ow==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertContainer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_insertContainer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertContainer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_insertContainer] @xmlVar XML
AS 

	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT



	/*Wstawienie danych o seriach dokumentów*/
    INSERT  INTO [warehouse].[Container] ( id,symbol,containerTypeId,xmlLabels,[name],xmlMetadata, version , [order], isActive)
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''symbol'').value(''.'', ''varchar(50)''),''''),
					NULLIF(con.query(''containerTypeId'').value(''.'', ''char(36)''),''''),
                    con.query(''xmlLabels/*''),
					con.query(''xmlLabels/*/label[1]'').value(''.'', ''varchar(50)''),
					con.query(''xmlMetadata/*''),
					NULLIF(con.query(''version'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''order'').value(''.'', ''int''),''''),
                    con.query(''isActive'').value(''.'', ''bit'')
            FROM    @xmlVar.nodes(''/root/*/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN

            SET @errorMsg = ''Błąd wstawiania danych table: Container ; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN

            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO
