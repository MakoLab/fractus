/*
name=[document].[p_insertSeries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
HhTBAbKAx60GwSMmRvV1KQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertSeries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertSeries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertSeries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_insertSeries]
@xmlVar XML
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    

	/*Wstawienie danych o seriach dokumentów*/
    INSERT  INTO [document].[Series]
            (
              id,
              numberSettingId,
              seriesValue,
			  lastNumber
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''numberSettingId'').value(''.'', ''char(36)''),
                    con.query(''seriesValue'').value(''.'', ''char(36)''),
					con.query(''lastNumber'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/series/entry'') AS C ( con )

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd wstawiania danych table:Series; error:''
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
