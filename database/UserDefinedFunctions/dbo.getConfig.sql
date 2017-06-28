/*
name=[dbo].[getConfig]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BK0jO00c7pgPvcjgETdGfA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[getConfig]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[getConfig]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[getConfig]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[getConfig]
( @string varchar(1000) )
RETURNS varchar(1000)
AS
BEGIN
	DECLARE @val nvarchar(4000)

	SELECT @val = CONVERT(nvarchar(4000), value )
	FROM sys.extended_properties AS p
	WHERE [name] like @string --(p.major_id=0 AND p.minor_id=0 AND p.class=0)
	
	SELECT @val =  NULLIF(@val,@string)
RETURN @val
END
' 
END

GO
