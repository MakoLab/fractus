/*
name=[communication].[p_createWarehouseStockPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2GtDZIjZ+9+3pwqyHHX8SQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createWarehouseStockPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createWarehouseStockPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createWarehouseStockPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createWarehouseStockPackage] @xmlVar XML
AS
BEGIN
	DECLARE 
		@xml XML,
		@localTransactionId UNIQUEIDENTIFIER,
        @deferredTransactionId UNIQUEIDENTIFIER,
		@databaseId UNIQUEIDENTIFIER

		SELECT
			@localTransactionId = x.value(''@localTransactionId'',''char(36)'') , 
			@deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
			@databaseId = x.value(''@databaseId'',''char(36)'')
		FROM @xmlVar.nodes(''root'') a(x) 

		SELECT @xml = (
		SELECT (
			SELECT (
				SELECT ws.* 
				FROM document.WarehouseStock ws 
				JOIN (
					SELECT DISTINCT
						x.query(''itemId'').value(''.'',''char(36)'') itemId, 
						x.query(''warehouseId'').value(''.'',''char(36)'') warehouseId 
					FROM @xmlVar.nodes(''root/entry'') a(x) 
					) sub ON ws.warehouseId = sub.warehouseId 
					AND ws.itemId = sub.itemId
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''warehouseStock''), TYPE 
			)FOR XML PATH(''root''), TYPE
		)

INSERT INTO communication.OutgoingXmlQueue (id, localTransactionId, deferredTransactionId,databaseId, type,xml, creationDate)
SELECT newid(), ISNULL(@localTransactionId, newid()), ISNULL(@deferredTransactionId, newid()), @databaseId,''WarehouseStock'', @xml, getdate()

END
' 
END
GO
