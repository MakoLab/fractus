/*
name=[dbo].[f_getGroupLabel_mod]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
chLTZ+KnrTUXGygcARLRxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getGroupLabel_mod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_getGroupLabel_mod]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getGroupLabel_mod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[f_getGroupLabel_mod]
( @id uniqueidentifier, @x xml )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @position int, @string varchar(500)

SELECT @string = x.value(''(labels/label[@lang="pl"])[1]'',''varchar(500)'') 
FROM @x.nodes(''//group'') as a(x)
WHERE x.value(''@id'',''varchar(500)'') = @id

RETURN @string
END
' 
END

GO
