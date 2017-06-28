/*
name=[dbo].[ex_SendMail]
version=1.0.1
lastUpdate=2017-01-24 10:37:21

*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ex_SendMail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ex_SendMail]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ex_SendMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ex_SendMail]
	@recipients [nvarchar](4000),
	@subject [nvarchar](4000),
	@from [nvarchar](4000),
	@body [nvarchar](4000)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [expressMail].[StoredProcedures].[ex_SendMail]' 
END
GO
