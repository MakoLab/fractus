/*
name=[document].[p_checkIncomeValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
N90IzGHNcHb/pKxF5y7doQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkIncomeValuation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkIncomeValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkIncomeValuation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_checkIncomeValuation] 
@warehouseDocumentHeaderId UNIQUEIDENTIFIER 

AS 
    BEGIN
		
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
				@rowcount INT

		DECLARE @tmp_WarehouseDoc TABLE (id int identity(1,1), warehouseDocumentHeaderId uniqueidentifier, stat int, version uniqueidentifier)
		DECLARE @tmp_CommercialDoc TABLE (id int identity(1,1), commercialDocumentHeaderId uniqueidentifier, stat int)

		IF EXISTS (
			SELECT  l.id
			FROM document.WarehouseDocumentLine l 
				LEFT JOIN ( SELECT SUM(ir.quantity) qty , ir.incomeWarehouseDocumentLineId  FROM document.IncomeOutcomeRelation ir GROUP BY  ir.incomeWarehouseDocumentLineId) xr ON l.id = xr.incomeWarehouseDocumentLineId
			WHERE  l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
				AND ISNULL(xr.qty,0) > 0
			)
			BEGIN
		
				IF EXISTS(
						SELECT SUM(ISNULL(y.qty,0))
						FROM document.WarehouseDocumentLine l
							LEFT JOIN (SELECT SUM(cv.quantity) qty , cv.warehouseDocumentLineId FROM document.CommercialWarehouseValuation cv GROUP BY cv.warehouseDocumentLineId ) x ON  x.warehouseDocumentLineId = l.id
							LEFT JOIN (SELECT SUM(v.quantity) qty , v.incomeWarehouseDocumentLineId FROM document.WarehouseDocumentValuation v GROUP BY v.incomeWarehouseDocumentLineId ) y ON l.id = y.incomeWarehouseDocumentLineId
						WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId --@warehouseDocumentHeaderId
						HAVING  SUM(ISNULL(y.qty,0)) > SUM(ISNULL(x.qty,0))
					) 
					BEGIN
						SELECT CAST( ''<root>true</root>'' AS XML ) XML 
						RETURN 0;
					END
					
				IF EXISTS (
						SELECT l.id
						FROM document.WarehouseDocumentLine l
							LEFT JOIN (SELECT SUM(v.quantity) qty , v.incomeWarehouseDocumentLineId FROM document.IncomeOutcomeRelation v GROUP BY v.incomeWarehouseDocumentLineId ) y ON l.id = y.incomeWarehouseDocumentLineId
							JOIN (
								SELECT SUM(v.quantity) qty , cv.warehouseDocumentLineId 
								FROM document.CommercialWarehouseValuation cv 
									 JOIN document.WarehouseDocumentValuation v ON cv.id = v.valuationId
								GROUP BY cv.warehouseDocumentLineId 
								) x ON  x.warehouseDocumentLineId = l.id
						WHERE y.qty <= x.qty
						)
						BEGIN
							SELECT CAST( ''<root>true</root>'' AS XML ) XML 
							RETURN 0;
						END
				      
			END
		ELSE
			BEGIN 
				SELECT CAST( ''<root>false</root>'' AS XML ) XML  
				RETURN 0;     
			END
			
		/*Obsługa błedów i wyjatków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:CommercialDocumentLine; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END

		SELECT CAST( ''<root>true</root>'' AS XML ) XML       
    END
' 
END
GO
