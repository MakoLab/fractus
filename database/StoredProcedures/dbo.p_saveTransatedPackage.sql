/*
name=[dbo].[p_saveTransatedPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BV4GqIixitGiVsY5tneoyg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_saveTransatedPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_saveTransatedPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_saveTransatedPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[p_saveTransatedPackage]
@type VARCHAR(50),
@sourceBranchId VARCHAR(36), 
@xml VARCHAR(MAX)
AS
BEGIN
	INSERT INTO [communication].[IncomingXmlQueue](id, localTransactionId, deferredTransactionId, databaseId, isComplited, [type], [xml], receiveDate, translationDate)
		VALUES(NEWID(), NEWID(), NEWID(), CAST(@sourceBranchId AS UNIQUEIDENTIFIER), 1, @type, CAST(@xml AS [xml]), GETDATE(), GETDATE())
END
' 
END
GO
