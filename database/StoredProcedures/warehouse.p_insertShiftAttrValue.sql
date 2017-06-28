/*
name=[warehouse].[p_insertShiftAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
w33jxTQ/twrHU7xCJXJ/KQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertShiftAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_insertShiftAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertShiftAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_insertShiftAttrValue]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o atrybutach dokumentu*/
    INSERT  INTO [warehouse].[ShiftAttrValue] WITH(TABLOCK)
            (
              id,
			  shiftId,
              shiftFieldId,
              decimalValue,
              dateValue,
              textValue,
              xmlValue,
              version
            )
    SELECT  con.query(''id'').value(''.'', ''char(36)''),
			NULLIF(con.query(''shiftId'').value(''.'', ''char(36)''),''''),
            con.query(''shiftFieldId'').value(''.'', ''char(36)''),
			NULLIF(con.query(''decimalValue'').value(''.'', ''varchar(500)''),''''),
            NULLIF(con.query(''dateValue'').value(''.'', ''datetime''), ''''),
            NULLIF(con.query(''textValue'').value(''.'', ''varchar(500)''),''''),
            CASE WHEN con.exist(''xmlValue'') = 1
                 THEN con.query(''xmlValue/*'')
                 ELSE NULL
            END,
            con.query(''version'').value(''.'', ''char(36)'')
    FROM    @xmlVar.nodes(''/root/shiftAttrValue/entry'') AS C ( con )
	
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:ShiftAttrValue; error:''
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
