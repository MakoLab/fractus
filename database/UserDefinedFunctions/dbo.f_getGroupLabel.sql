/*
name=[dbo].[f_getGroupLabel]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6CIuk9r66Gk4SHAS3mJRtg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getGroupLabel]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_getGroupLabel]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getGroupLabel]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_getGroupLabel]
( @id uniqueidentifier, @x xml )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @position int, @string varchar(500)

SELECT @string = x.value(''(//group/labels/label)[1]'',''varchar(500)'') 
FROM @x.nodes(''*'') as a(x)
WHERE x.value(''(//group/@id)[1]'',''varchar(500)'') = @id

RETURN @string
END' 
END

GO
