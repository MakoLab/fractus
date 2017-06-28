/*
name=[configuration].[p_deleteConfigurationById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xmx8z7+LI5B+0PsWCUFnuQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_deleteConfigurationById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_deleteConfigurationById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_deleteConfigurationById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [configuration].[p_deleteConfigurationById] 
   @configurationId UNIQUEIDENTIFIER
AS
BEGIN
	
	DELETE FROM configuration.Configuration 
	WHERE id = @configurationId

END
' 
END
GO
