/*
name=[custom].[makolabGetGroupPath]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
LPBbipDmm7Ih1PqnUPL/jw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabGetGroupPath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [custom].[makolabGetGroupPath]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabGetGroupPath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [custom].[makolabGetGroupPath] ( @id uniqueidentifier )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @string varchar(500), @child uniqueidentifier, @parent uniqueidentifier,  @x xml;

SELECT @X = C.xmlValue FROM configuration.Configuration AS C WHERE [C].[KEY] = ''items.group''

SET @child = @id
SET @string = ''''

while @child <> ''7728DF62-9C11-473B-A7A7-BA2AC0792507''
begin
	SELECT @string = x.value(''(labels/label[@lang="pl"])[1]'',''varchar(500)'') + ''->'' + @string, 
			@parent = x.value(''(../../@id)[1]'',''varchar(500)'')
	FROM @x.nodes(''//group'') as a(x)
	WHERE x.value(''@id'',''varchar(500)'') = @child

	SET @child = @parent
end

SELECT @string =
CASE
    WHEN RIGHT(@string, 2) = ''->'' THEN SUBSTRING(@string, 1, LEN(@string) -2)
	ELSE @string
END	

RETURN REPLACE(@string, ''Grupy towarowe->'', '''')
END


' 
END

GO
