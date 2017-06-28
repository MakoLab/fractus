/*
name=[document].[p_updateIncomeOutcomeRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hlnBw07phJJDCd5j6RahYg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateIncomeOutcomeRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateIncomeOutcomeRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateIncomeOutcomeRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateIncomeOutcomeRelation]
@xmlVar XML
AS
BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT

        
        
		/*Aktualizacja pozycji powiązań ilościowych dokumentu magazynowego*/
        UPDATE  [document].IncomeOutcomeRelation
        SET     incomeWarehouseDocumentLineId = CASE WHEN con.exist(''incomeWarehouseDocumentLineId'') = 1
                                                  THEN con.query(''incomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                outcomeWarehouseDocumentLineId = CASE WHEN con.exist(''outcomeWarehouseDocumentLineId'') = 1
                                     THEN con.query(''outcomeWarehouseDocumentLineId'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END,
                incomeDate = CASE WHEN con.exist(''incomeDate'') = 1
                                     THEN con.query(''incomeDate'').value(''.'', ''datetime'')
                                     ELSE NULL
                                END,
                quantity = CASE WHEN con.exist(''quantity'') = 1
                                THEN con.query(''quantity'').value(''.'', ''numeric(18,6)'')
                                ELSE NULL
                           END
        FROM    @xmlVar.nodes(''/root/incomeOutcomeRelation/entry'') AS C ( con )
        WHERE   IncomeOutcomeRelation.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: IncomeOutcomeRelation; error:''
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
