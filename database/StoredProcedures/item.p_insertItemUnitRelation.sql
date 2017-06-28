/*
name=[item].[p_insertItemUnitRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WX0uW99835xZnctkiO3VSg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemUnitRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItemUnitRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemUnitRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_insertItemUnitRelation]
@xmlVar XML
AS
DECLARE @errorMsg varchar(2000),
        @rowcount int

    
    
    /*Wstawienie danych o powiązaniach towarów z jednostkami miar*/
    INSERT  INTO [item].[ItemUnitRelation]
            (
              id,
              itemId,
              unitId,
              precision,
              version
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''itemId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''unitId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''precision'').value(''.'', ''decimal(16,8)''),''''),
                    NULLIF(con.query(''version'').value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/itemUnitRelation/entry'') AS C ( con )

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table: ItemUnitRelation; error:''
                + cast(@@error as varchar(50)) + ''; ''
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
