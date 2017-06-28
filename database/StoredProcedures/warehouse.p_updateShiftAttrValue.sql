/*
name=[warehouse].[p_updateShiftAttrValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wUx+v9D2iBdxz7F4Ny8Cjg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateShiftAttrValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_updateShiftAttrValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateShiftAttrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_updateShiftAttrValue] @xmlVar XML  
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    BEGIN
        
		/*Aktualizacja danych o wartościach atrybutów Shift*/
        UPDATE  [warehouse].[ShiftAttrValue]
        SET    
				shiftId = CASE WHEN con.exist(''shiftId'') = 1
                                                  THEN con.query(''shiftId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                shiftFieldId = CASE WHEN con.exist(''shiftFieldId'') = 1
                                       THEN con.query(''shiftFieldId'').value(''.'', ''char(36)'')
                                       ELSE NULL
                                  END,
                decimalValue = CASE WHEN con.exist(''decimalValue'') = 1
                                    THEN con.query(''decimalValue'').value(''.'', ''decimal(18,4)'')
                                    ELSE NULL
                               END,
                textValue = CASE WHEN con.exist(''textValue'') = 1
                                 THEN con.query(''textValue'').value(''.'', ''nvarchar(500)'')
                                 ELSE NULL
                            END,
                xmlValue = CASE WHEN con.exist(''xmlValue'') = 1
                                THEN con.query(''xmlValue/*'')
                                ELSE NULL
                           END,
                dateValue = CASE WHEN con.exist(''dateValue'') = 1
                                    THEN con.query(''dateValue'').value(''.'', ''datetime'')
                                    ELSE NULL
                               END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/shiftAttrValue/entry'') AS C ( con )
        WHERE   ShiftAttrValue.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN

                SET @errorMsg = ''Błąd wstawiania danych table:ShiftAttrValue; error:''
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
