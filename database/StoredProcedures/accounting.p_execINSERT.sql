/*
name=[accounting].[p_execINSERT]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
oLpJN6OrWjiowymwr/6vmw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_execINSERT]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_execINSERT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_execINSERT]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE accounting.p_execINSERT @x xml
AS
BEGIN
EXEC [CDNXL_MOTOMAR].[dbo].[fractusExportContractor] @x
END' 
END
GO
