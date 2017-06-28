/*
name=[dictionary].[p_getAutoDictionaryValues]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YBhNp+GKHEHMyAGhwOm1EA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getAutoDictionaryValues]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getAutoDictionaryValues]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getAutoDictionaryValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dictionary].[p_getAutoDictionaryValues]
	@xmlVar xml
AS

	SELECT
	(
		SELECT DISTINCT F.name ''@attribute'', V.textValue ''@value''
		FROM item.ItemAttrValue V
		JOIN dictionary.ItemField F ON F.id = V.itemFieldId
		WHERE xmlMetadata.value(''(/*/autoDictionary)[1]'', ''char(1)'') = 1
		ORDER BY name ASC, textValue ASC
		FOR XML PATH(''value''), TYPE
	) FOR XML PATH(''values''), TYPE
' 
END
GO
