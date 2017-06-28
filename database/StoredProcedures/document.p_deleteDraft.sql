/*
name=[document].[p_deleteDraft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iwNP80LG3eSro91Ncx+aGw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteDraft]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_deleteDraft]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_deleteDraft]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE document.p_deleteDraft @xmlVar XML
AS
BEGIN
DECLARE @id char(36)

SELECT @id = @xmlVar.value(''(root/id)[1]'',''char(36)'')

DELETE FROM document.Draft WHERE id = @id

IF @@error <> 0 
	SELECT CAST(''<root>Błąd kasowania</root>'' as XML) returnXml
ELSE
	SELECT CAST(''<root></root>'' as XML) returnXml
END' 
END
GO
