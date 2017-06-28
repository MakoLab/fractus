/*
name=[document].[p_insertWarehouseDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
rLeNIoJDIqKpnt+/umG4mg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertWarehouseDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertWarehouseDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertWarehouseDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertWarehouseDocumentLine] @xmlVar XML
AS 
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int,
			@error int 
    
	BEGIN TRY

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		INSERT  INTO [document].WarehouseDocumentLine
				(
				  id,
				  warehouseDocumentHeaderId,
				  direction,
				  itemId,
				  warehouseId,
				  unitId,
				  quantity,
				  price,
				  [value],
				  incomeDate,
				  outcomeDate,
				  ordinalNumber,
				  [description],
				  version,
				  isDistributed,
				  previousIncomeWarehouseDocumentLineId ,
				  correctedWarehouseDocumentLineId ,
				  initialWarehouseDocumentLineId,
				  lineType   
				)
		SELECT
				  id,
				  warehouseDocumentHeaderId,
				  direction,
				  itemId,
				  warehouseId,
				  unitId,
				  quantity,
				  price,
				  [value],
				  incomeDate,
				  outcomeDate,
				  ordinalNumber,
				  [description],
				  ISNULL([_version],[version]),
				  isDistributed,
				  previousIncomeWarehouseDocumentLineId ,
				  correctedWarehouseDocumentLineId ,
				  initialWarehouseDocumentLineId,
				  lineType
		FROM OPENXML(@idoc, ''/root/warehouseDocumentLine/entry'')
			WITH (
					id char(36) ''id'',
					warehouseDocumentHeaderId char(36) ''warehouseDocumentHeaderId'',
					direction int ''direction'',
					itemId char(36) ''itemId'',
					warehouseId char(36) ''warehouseId'',
					unitId char(36) ''unitId'',
					quantity numeric(18,6) ''quantity'',
					price numeric(16,2) ''price'',
					[value] numeric(16,2) ''value'',
					incomeDate datetime ''incomeDate'',
					outcomeDate datetime ''outcomeDate'',
					[description] nvarchar(500) ''description'',
					ordinalNumber int ''ordinalNumber'',
					version char(36) ''version'',
					_version char(36) ''_version'',
					isDistributed bit ''isDistributed'',
					previousIncomeWarehouseDocumentLineId char(36) ''previousIncomeWarehouseDocumentLineId'',
					correctedWarehouseDocumentLineId char(36) ''correctedWarehouseDocumentLineId'',
					initialWarehouseDocumentLineId  char(36) ''initialWarehouseDocumentLineId'',
					lineType  int ''lineType''
				)

		/*Pobranie liczby wierszy*/
		SET @rowcount = @@ROWCOUNT
		EXEC sp_xml_removedocument @idoc

     END TRY
	 BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Item; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC [document].[p_insertWarehouseDocumentLine] @xmlVar
		END
END
' 
END
GO
