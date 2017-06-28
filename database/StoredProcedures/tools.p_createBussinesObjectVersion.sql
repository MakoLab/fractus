/*
name=[tools].[p_createBussinesObjectVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YQX9y2Czb66fVCqGDNQWIQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_createBussinesObjectVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_createBussinesObjectVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_createBussinesObjectVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [tools].[p_createBussinesObjectVersion] @xmlVar xml OUTPUT , @branchId uniqueidentifier = null
as
BEGIN
	SELECT @xmlVar =
	(SELECT 
	 (
		SELECT (SELECT id FROM dictionary.Branch WHERE databaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] like ''communication.databaseId'')) as ''@branchId'',
		''ComparisionDataResponse'' ''@typ''
		, (
				SELECT 
					''WarehouseDocumentHeader'' ''@typ'',
					h.id ''@id'',
					h.[version] ''@version'',
					h.[modificationDate] ''@modificationDate'',
					dt.symbol ''@symbol'',
					dbo.xp_agregate(CAST(h.[version] as char(36)) + 
									ISNULL(CAST([contractorId] as char(36)),'''') +
									fullNumber +
									CAST(issueDate as char(36)) +
									ISNULL(CAST( value as char(36)),'''') +
									CAST([seriesId] as char(36)) +
									ISNULL(CAST([modificationDate] as char(36)),'''') +
									CAST([status] as char(36)) 
									) ''@_CHECKSUM''
				FROM document.WarehouseDocumentHeader h
				JOIN dictionary.DocumentType dt ON h.documentTypeId= dt.id
				WHERE (h.branchId = @branchId OR @branchId IS NULL ) AND 
					YEAR(issueDate) = YEAR(getdate())
					AND dt.symbol NOT IN ( ''MM+'',''MM-'',''ZMM'' )
				GROUP BY h.id, h.branchId, h.[modificationDate], h.[version], dt.symbol
				FOR XML PATH(''object''),TYPE
				),(
				SELECT 
					''CommercialDocumentHeader'' ''@typ'',
					h.id ''@id'',
					h.[version] ''@version'',
					[modificationDate] ''@modificationDate'',
					dt.symbol ''@symbol'',
					dbo.xp_agregate(CAST(h.[version] as char(36)) + 
									ISNULL(CAST([contractorId] as char(36)),'''') +
									fullNumber +
									CAST(issueDate as char(36)) +
									ISNULL(CAST( grossValue as char(36)),'''') +
									CAST([seriesId] as char(36)) +
									ISNULL(CAST([modificationDate] as char(36)),'''') +
									CAST([status] as char(36)) 
									) ''@_CHECKSUM''
				FROM document.CommercialDocumentHeader h
				JOIN dictionary.DocumentType dt ON h.documentTypeId= dt.id
				WHERE branchId = @branchId OR @branchId IS NULL
				GROUP BY h.id, h.branchId, h.[modificationDate], h.[version], dt.symbol
				FOR XML PATH(''object''),TYPE
				)
				FOR XML PATH(''root''),TYPE
			)	
			FOR XML PATH(''root''),TYPE
		) 
END
' 
END
GO
