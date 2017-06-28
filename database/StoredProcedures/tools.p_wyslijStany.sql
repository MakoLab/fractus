/*
name=[tools].[p_wyslijStany]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
awdU5cpdX6djf2Hp9Kflow==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_wyslijStany]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_wyslijStany]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_wyslijStany]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_wyslijStany]
AS

DECLARE @tempTab TABLE 
		(
			[lp] INT IDENTITY(1,1) PRIMARY KEY,
			[id] [uniqueidentifier] NOT NULL,
			[warehouseId] [uniqueidentifier] NOT NULL,
			[itemId] [uniqueidentifier] NOT NULL,
			[unitId] [uniqueidentifier] NOT NULL,
			[quantity] [numeric](18, 6) NOT NULL,
			[reservedQuantity] [numeric](18, 6) NULL,
			[orderedQuantity] [numeric](18, 6) NULL,
			[isBlocked] [int] NULL,
			[lastPurchaseNetPrice] [numeric](18, 2) NULL,
			[lastPurchaseIssueDate] [datetime] NULL
		)
DECLARE @rowNumber INT
DECLARE @i INT
DECLARE @current UNIQUEIDENTIFIER
DECLARE @xml XML
DECLARE @databaseId UNIQUEIDENTIFIER

SET @i = 0

SELECT @databaseId = CAST(textValue as uniqueidentifier)
FROM configuration.Configuration 
WHERE [key] = ''communication.databaseId''
		
INSERT INTO @tempTab
SELECT * FROM document.WarehouseStock
WHERE itemId IN (SELECT DISTINCT itemId FROM document.WarehouseDocumentLine)
AND warehouseId IN (SELECT id FROM dictionary.Warehouse where branchId = 
(SELECT id FROM dictionary.Branch WHERE databaseId = @databaseId))

SELECT @rowNumber = count(*) FROM @tempTab

WHILE @i < @rowNumber
	BEGIN		
		SELECT @xml = 
		(
			SELECT 
			(
				SELECT 
				(
					SELECT top 100 * 
					FROM @tempTab
					ORDER BY lp
					FOR XML PATH(''entry''), TYPE 
				)
				FOR XML PATH(''warehouseStock''), TYPE 
			)
			FOR XML PATH(''root''), TYPE
		)

		INSERT INTO communication.OutgoingXmlQueue (id, localTransactionId, deferredTransactionId, databaseId, type, xml, creationDate)
		SELECT newid(), newid(), newid(), @databaseId, ''WarehouseStock'', @xml, getdate()

		SET @i = @i + 100
		DELETE FROM @tempTab WHERE lp <= @i
	END
' 
END
GO
