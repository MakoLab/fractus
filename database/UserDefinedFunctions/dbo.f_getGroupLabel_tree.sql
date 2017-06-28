/*
name=[dbo].[f_getGroupLabel_tree]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
J7xAMlS9gMMwN7DijNSiJw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getGroupLabel_tree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_getGroupLabel_tree]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getGroupLabel_tree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[f_getGroupLabel_tree]
( @id uniqueidentifier, @x xml, @sep varchar(50) = null )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @string varchar(500), @child uniqueidentifier, @parent uniqueidentifier

SET @child = @id
SET @string = ''''

while @child <> ''7728DF62-9C11-473B-A7A7-BA2AC0792507''
begin
	SELECT @string = x.value(''(labels/label[@lang="pl"])[1]'',''varchar(500)'') + ISNULL(@sep, '' '') + @string, 
			@parent = x.value(''(../../@id)[1]'',''varchar(500)'')
	FROM @x.nodes(''//group'') as a(x)
	WHERE x.value(''@id'',''varchar(500)'') = @child

	SET @child = @parent
end


RETURN @string
END
' 
END

GO
