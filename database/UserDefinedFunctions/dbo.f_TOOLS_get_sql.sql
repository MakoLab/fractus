/*
name=[dbo].[f_TOOLS_get_sql]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+Wsif9nDMvRf0GQtQYpgjw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_TOOLS_get_sql]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_TOOLS_get_sql]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_TOOLS_get_sql]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_TOOLS_get_sql]
( 
	@spid int
)
RETURNS 
	VARCHAR(8000)
 
AS
BEGIN
		DECLARE @a varchar(8000), @Handle BINARY(20)
		SELECT @Handle = sql_handle FROM master.dbo.sysprocesses WHERE spid = @spid 
		SELECT @a = text FROM ::fn_get_sql(@Handle)
RETURN @a
END
' 
END

GO
