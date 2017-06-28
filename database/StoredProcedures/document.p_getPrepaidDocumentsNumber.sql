/*
name=[document].[p_getPrepaidDocumentsNumber]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Rrqnp/V+quefeVWH7MMe1A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPrepaidDocumentsNumber]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getPrepaidDocumentsNumber]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getPrepaidDocumentsNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [document].[p_getPrepaidDocumentsNumber]
@xmlVar XML
AS
BEGIN
	DECLARE @count INT, @id UNIQUEIDENTIFIER
	
	SELECT @id = @xmlVar.value(''(/root/commercialDocumentHeaderId)[1]'',''char(36)'')
	
	SELECT @count = COUNT(dr.secondCommercialDocumentHeaderId )
	FROM document.DocumentRelation dr
	WHERE dr.relationType=9 AND dr.firstCommercialDocumentHeaderId = @id
	
	SELECT ISNULL(@count,0) number FOR XML PATH(''root''),TYPE
	
END' 
END
GO
