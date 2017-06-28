/*
name=[custom].[p_getAllDocumentsReport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
kjRlycnGi49f/M2OlwFn9w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getAllDocumentsReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getAllDocumentsReport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getAllDocumentsReport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [custom].[p_getAllDocumentsReport]
@xmlVar XML 
AS
BEGIN
	
	SET NOCOUNT ON;

    
	SELECT * FROM tempv_allDocuments
END
' 
END
GO
