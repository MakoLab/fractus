/*
name=[document].[xp_commercialDocumentDictionaryInsert]
version=1.0.1
lastUpdate=2017-01-24 10:37:21

*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_commercialDocumentDictionaryInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[xp_commercialDocumentDictionaryInsert]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_commercialDocumentDictionaryInsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[xp_commercialDocumentDictionaryInsert]
	@Col1 [nvarchar](4000),
	@rowId [uniqueidentifier],
	@regExp [xml]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [xp_commercialDocumentDictionary].[StoredProcedures].[xp_commercialDocumentDictionaryInsert]' 
END
GO