/*
name=[contractor].[p_insertEmployee]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ghlKH180umyOmUarw3pYOw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertEmployee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertEmployee]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertEmployee]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertEmployee]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o pracownikach*/
    INSERT  INTO contractor.Employee
            (
              contractorId,
              jobPositionId,
              version
            )
            SELECT  NULLIF(con.query(''contractorId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''jobPositionId'').value(''.'', ''char(36)''),''''),
                    con.query(''jobPositionId'').value(''.'', ''char(36)'')
            FROM    @xmlVar.nodes(''/root/employee/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT

	/*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:Employee; error:''
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
