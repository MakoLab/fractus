/*
name=[document].[v_commercialDocumentDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VK+5T4KRGZQL0L95JNv7AQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_commercialDocumentDictionary]'))
DROP VIEW [document].[v_commercialDocumentDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[document].[v_commercialDocumentDictionary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [document].[v_commercialDocumentDictionary] WITH SCHEMABINDING AS
SELECT    COUNT_BIG(*) counter, [document].CommercialDocumentDictionary.field, 
	[document].CommercialDocumentDictionary.id,
	[document].CommercialDocumentDictionaryRelation.commercialDocumentHeaderId
FROM         [document].CommercialDocumentDictionary INNER JOIN
                      [document].CommercialDocumentDictionaryRelation ON 
                      [document].CommercialDocumentDictionary.id = [document].CommercialDocumentDictionaryRelation.commercialDocumentDictionaryId
GROUP BY [document].CommercialDocumentDictionary.field, [document].CommercialDocumentDictionaryRelation.commercialDocumentHeaderId, [document].CommercialDocumentDictionary.id
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
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[document].[v_commercialDocumentDictionary]') AND name = N'indVCommercailDOcumentDictionary')
CREATE UNIQUE CLUSTERED INDEX [indVCommercailDOcumentDictionary] ON [document].[v_commercialDocumentDictionary]
(
	[commercialDocumentHeaderId] ASC,
	[field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
