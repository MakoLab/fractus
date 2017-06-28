/*
name=[tools].[p_crInsert]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
biNOcdOAgtO+49vOYYP0sA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_crInsert]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_crInsert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_crInsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_crInsert] --''ServiceHeader'', ''service'', ''''
 
@TABLE varchar(500), 
@schema varchar(500), 
@FROM varchar(500)
 
AS
 
BEGIN
	DECLARE 
	@out varchar(max),
	@list varchar(max) 
 
 
	SELECT @list = CAST( (SELECT ''['' + [name] + ''], '' AS ''data()'' FROM sys.COLUMNS WHERE object_id = (SELECT top 1 object_id  FROM sys.TABLES WHERE [name] =  @TABLE ) FOR XML PATH(''''), TYPE) AS varchar(max) )
	SELECT @list = SUBSTRING( @list, 1, LEN(@list) - 1 ) 
 
 
	SELECT  @out =  (
		SELECT ''INSERT INTO ''  + @schema + ''.'' + @TABLE + '' ('' + @list  + '') '' + char(10)  + char(10) +''SELECT '' + @list  + char(10)  + ''FROM '' + @FROM + ''.'' + @schema + ''.'' + @TABLE 
 
	)
 
	SELECT @out
END
' 
END
GO
