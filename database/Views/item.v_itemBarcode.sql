/*
name=[item].[v_itemBarcode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
kai/vKYD97Oike50U9QAAQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemBarcode]'))
DROP VIEW [item].[v_itemBarcode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[item].[v_itemBarcode]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [item].[v_itemBarcode] WITH SCHEMABINDING AS

SELECT  COUNT_BIG(*) counter, it.name itemName, it.code , it.id itemId, i.textValue textValue, i.itemFieldId ,it.unitId
FROM item.itemAttrValue i 
	JOIN item.Item it ON i.itemId = it.id
WHERE NULLIF(i.textValue,'''') IS NOT NULL
GROUP BY it.name , it.code , it.id,  i.textValue, i.itemFieldId  ,it.unitId
' 
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[v_itemBarcode]') AND name = N'ind_vItemBarcode')
CREATE UNIQUE CLUSTERED INDEX [ind_vItemBarcode] ON [item].[v_itemBarcode]
(
	[textValue] ASC,
	[itemFieldId] ASC,
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
