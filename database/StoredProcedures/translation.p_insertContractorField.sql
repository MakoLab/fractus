/*
name=[translation].[p_insertContractorField]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YzWyI71Mg67TGldmVZkINw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertContractorField]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertContractorField]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertContractorField]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertContractorField] @attributeName VARCHAR(50), @labelPL VARCHAR(50), @labelEN VARCHAR(50) AS
BEGIN	
	DELETE FROM dictionary.ContractorField WHERE [name] = @attributeName
	INSERT INTO dictionary.ContractorField([id],[name],[xmlLabels],[xmlMetadata],[version],[order])
	SELECT	
		NEWID() as [id],
		(SELECT @attributeName) as [name],
		(SELECT
			(SELECT ''pl'' as ''@lang'', (SELECT @labelPL as label) FOR XML PATH(''label''), TYPE),
            (SELECT ''en'' as ''@lang'', (SELECT @labelEN as label) FOR XML PATH(''label''), TYPE)
		FOR XML PATH(''labels''), TYPE) as [xmlLabels],
		''<metadata><dataType>string</dataType></metadata>'' as [xmlMetadata],
		NEWID()as [version],
		(SELECT MAX([order]) + 1 FROM dictionary.ContractorField) as [order]
	
END
' 
END
GO
