/*
name=[warehouse].[p_insertShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
kfLJ+uzd9rogvZh4tI3pRw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertShift]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_insertShift]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertShift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_insertShift] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	/*Wstawienie danych o pozycjach dokumentu handlowego*/
    INSERT  INTO [warehouse].[Shift]
            (
              id,
              shiftTransactionId,
              incomeWarehouseDocumentLineId,
			  warehouseId,
			  containerId,
              quantity,
			  warehouseDocumentLineId,
			  sourceShiftId,
              status,
			  ordinalNumber,
			  version
            )
            SELECT 
              id,
              shiftTransactionId,
              incomeWarehouseDocumentLineId,
			  warehouseId,
			  containerId,
              quantity,
			  warehouseDocumentLineId,
			  sourceShiftId,
              status,
			  ordinalNumber,
			  version

			FROM OPENXML(@idoc, ''/root/shift/entry'')
				WITH(
					id char(36) ''id'',
                    shiftTransactionId char(36) ''shiftTransactionId'',
                    incomeWarehouseDocumentLineId char(36) ''incomeWarehouseDocumentLineId'',
					warehouseId char(36) ''warehouseId'',
					containerId char(36) ''containerId'',
                    quantity numeric(18,6) ''quantity'',
					warehouseDocumentLineId char(36) ''warehouseDocumentLineId'',
                    sourceShiftId char(36) ''sourceShiftId'',
                    status int ''status'',
					ordinalNumber int ''ordinalNumber'',
					version char(36) ''version''

             )
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Shift; error:''
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
