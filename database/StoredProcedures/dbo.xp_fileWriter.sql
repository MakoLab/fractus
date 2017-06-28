/*
name=[dbo].[xp_fileWriter]
version=1.0.1
lastUpdate=2017-01-24 10:37:21

*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xp_fileWriter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[xp_fileWriter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xp_fileWriter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xp_fileWriter]
	@file_name [nvarchar](4000),
	@content [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [xp_fileWriter].[StoredProcedures].[xp_fileWriter]' 
END
GO
