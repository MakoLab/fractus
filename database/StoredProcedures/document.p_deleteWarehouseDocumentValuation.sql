/*
name=[document].[p_deleteWarehouseDocumentValuation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
i60SCrlsKAeGEKD1WribfA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentValuation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteWarehouseDocumentValuation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteWarehouseDocumentValuation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_deleteWarehouseDocumentValuation] @xmlVar XML
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
 
    DECLARE @tmp TABLE (id uniqueidentifier)
    INSERT INTO @tmp
    SELECT  NULLIF(con.query(''id'').value(''.'', ''char(36)''), '''')
    FROM    @xmlVar.nodes(''/root/warehouseDocumentValuation/entry'') AS C ( con )
    /*Kasowanie danych o wycenie pozycji dokumentu magazynowego*/
    DELETE  FROM [document].WarehouseDocumentValuation
    WHERE   id IN ( SELECT  id FROM @tmp)

	/*Pobieranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            SET @errorMsg = ''Błąd kasowania danych:WarehouseDocumentValuation; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
' 
END
GO
