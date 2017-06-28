/*
name=[contractor].[p_insertBank]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZqxWUvDRYE6y7TUm1S/PcQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertBank]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertBank]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertBank]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertBank]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    /*Wstawienie wierszy o bankach*/
    INSERT  INTO contractor.Bank
            (
              contractorId,
              bankNumber,
              swiftNumber,
              version
            )
            SELECT  NULLIF(con.query(''contractorId'').value(''.'', ''char(36)''),
                           ''''),
                    NULLIF(con.query(''bankNumber'').value(''.'', ''varchar(100)''),
                           ''''),
                    NULLIF(con.query(''swiftNumber'').value(''.'', ''varchar(20)''),
                           ''''),
                    NULLIF(con.query(''version'').value(''.'', ''char(36)''), '''')
            FROM    @xmlVar.nodes(''/root/bank/entry'') AS C ( con )
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Bank; error:''
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
