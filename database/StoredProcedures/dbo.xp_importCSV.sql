/*
name=[dbo].[xp_importCSV]
version=1.0.1
lastUpdate=2017-01-24 10:37:21

*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xp_importCSV]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[xp_importCSV]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xp_importCSV]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xp_importCSV]
	@URI [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [xp_valuateOutcome].[StoredProcedures].[xp_importCSV]' 
END
GO
