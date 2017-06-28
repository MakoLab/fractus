/*
name=[document].[p_getDocumentContractorFullName]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JNvD6qqSAlzSk3lfzD1Thg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentContractorFullName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDocumentContractorFullName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentContractorFullName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getDocumentContractorFullName] 
@commercialDocumentHeaderId UNIQUEIDENTIFIER
AS
BEGIN

SELECT 
	( SELECT ( SELECT fullName FROM contractor.Contractor WHERE id = h.contractorId )
	FROM document.CommercialDocumentHeader h
	WHERE h.id = @commercialDocumentHeaderId
) FOR XML PATH(''root''), TYPE

END
' 
END
GO
