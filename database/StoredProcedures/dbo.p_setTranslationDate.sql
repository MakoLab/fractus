/*
name=[dbo].[p_setTranslationDate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
sBgCNh/GLHAJq2eJNfIiGw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_setTranslationDate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_setTranslationDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_setTranslationDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[p_setTranslationDate]
@id VARCHAR(36)
AS
BEGIN
	UPDATE [communication].[IncomingXmlQueue]
		SET translationDate = GETDATE()
		WHERE id = CAST(@id AS UNIQUEIDENTIFIER)
END
' 
END
GO
