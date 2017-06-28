/*
name=[accounting].[f_getExternalMapping]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NkfdJo/BgQZSql8pel54MA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[f_getExternalMapping]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [accounting].[f_getExternalMapping]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[f_getExternalMapping]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [accounting].[f_getExternalMapping]( @symbol varchar(50), @key varchar(500))
returns varchar(50)
AS
	BEGIN

		DECLARE @extSymbol varchar(50)

		SELECT @extSymbol = xmlValue.value(''(root/entry[localSymbol=sql:variable("@symbol") ]/externalSymbol)[1]'',''varchar(50)'') 
		FROM configuration.Configuration 
		WHERE [key] = @key

		IF @extSymbol IS NULL
			SELECT @extSymbol = CAST(''!!Brak mapowania wartości '' + @symbol as int)

	RETURN @extSymbol;

	END
' 
END

GO
