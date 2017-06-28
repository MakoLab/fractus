/*
name=[item].[p_insertItemRelationAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MSVNxCWTcw28HYbhNYmznw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemRelationAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItemRelationAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemRelationAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_insertItemRelationAttrValue]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Wstawienie danych o wartościach atrybutów powiązań dla towarów*/
    INSERT  INTO [item].[ItemRelationAttrValue]
            (
              id,
              itemRelationId,
              itemRAVTypeId,
              decimalValue,
              dateValue,
              textValue,
              xmlValue,
              version,
              [order]
            )
            SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''itemRelationId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''itemRAVTypeId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''decimalValue'').value(''.'', ''varchar(500)''),''''),
                    NULLIF(con.query(''dateValue'').value(''.'', ''datetime''), ''''),
                    NULLIF(con.query(''textValue'').value(''.'', ''varchar(500)''), ''''),
                    CASE WHEN con.exist(''xmlValue'') = 1
                         THEN con.query(''xmlValue/*'')
                         ELSE NULL
                    END,
                    NULLIF(con.query(''version'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''order'').value(''.'', ''int''), '''')
            FROM    @xmlVar.nodes(''/root/itemRelationAttrValue/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:ItemRelationAttrValue; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
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
