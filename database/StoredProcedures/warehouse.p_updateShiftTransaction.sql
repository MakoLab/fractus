/*
name=[warehouse].[p_updateShiftTransaction]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yU1Krt45eD6pItb/PnSSlw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateShiftTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_updateShiftTransaction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateShiftTransaction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_updateShiftTransaction] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
    BEGIN 

		/*Aktualizacja danych o przesunięciach wewnątrz magazynowych*/
        UPDATE  warehouse.ShiftTransaction
        SET     applicationUserId = CASE WHEN con.exist(''applicationUserId'') = 1
                                                  THEN con.query(''applicationUserId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                issueDate = CASE WHEN con.exist(''issueDate'') = 1
                                 THEN con.query(''issueDate'').value(''.'', ''datetime'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END,
                [description] = CASE WHEN con.exist(''description'') = 1
                               THEN con.query(''description'').value(''.'', ''nvarchar(500)'')
                               ELSE NULL
                          END,
                reasonId = CASE WHEN con.exist(''reasonId'') = 1
                               THEN con.query(''reasonId'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END

        FROM    @xmlVar.nodes(''/root/shiftTransaction/entry'') AS C ( con )
        WHERE   ShiftTransaction.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: ShiftTransaction; error:''
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
