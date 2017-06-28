/*
name=[dbo].[p_searchDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
jBfgRlpAIoX3jpm25JkSmw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_searchDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_searchDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_searchDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE p_searchDictionary
@text nvarchar(255)
AS
SELECT @text = ''%'' + @text + ''%''
SELECT ''commercialDocument'', * 
FROM [document].CommercialDocumentDictionary WHERE field like @text
UNION
SELECT ''item'',* 
FROM item.ItemDictionary where field like @text
UNION
SELECT ''contractor'', * 
FROM contractor.ContractorDictionary where field like @text' 
END
GO
