/*
name=[warehouse].[p_insertShiftTransaction]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
81dSs7Q4simuX78nJ8xnFg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertShiftTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_insertShiftTransaction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertShiftTransaction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_insertShiftTransaction] @xmlVar XML
AS 

	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT



	/*Wstawienie danych o seriach dokumentów*/
    INSERT  INTO [warehouse].[ShiftTransaction]
            ( id,applicationUserId,issueDate,version,[description], reasonId )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''applicationUserId'').value(''.'', ''char(36)''),
                    con.query(''issueDate'').value(''.'', ''datetime''),
					con.query(''version'').value(''.'', ''char(36)''),
                    NULLIF(con.query(''description'').value(''.'', ''nvarchar(500)''),''''),
                    NULLIF(con.query(''reasonId'').value(''.'', ''char(36)''),'''')
            FROM    @xmlVar.nodes(''/root/*/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN

            SET @errorMsg = ''Błąd wstawiania danych table:ShiftTransaction; error:''
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
