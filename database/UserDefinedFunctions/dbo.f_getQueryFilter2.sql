/*
name=[dbo].[f_getQueryFilter2]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bJBfZpju+gWILnTsm1jP1g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getQueryFilter2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_getQueryFilter2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getQueryFilter2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_getQueryFilter2] ( @query nvarchar(4000) ,@replaceConf varchar(8000), @join varchar(500) ,@select varchar(500), @view nvarchar(500), @view2 nvarchar(500) , @view3 nvarchar(500), @view4 nvarchar(500) )
RETURNS varchar(max)
AS
BEGIN
DECLARE @string nvarchar(max), @i int
DECLARE @tmp_word TABLE
	(
	  id INT IDENTITY(1, 1),
	  word NVARCHAR(100)
	)

	SELECT  @string = '' '', @i = 0
	
	/*Dzielenie wyrażenia query na słowa*/	
	INSERT  INTO @tmp_word ( word )
	SELECT DISTINCT  word
	FROM    xp_split(dbo.f_replace2(@query,@replaceConf),  '' '')
	WHERE RTRIM(word) <> ''''
		
	WHILE @@rowcount > 0
		BEGIN
			SET @i = @i + 1
			
			SELECT  @string = @string
					+ '' JOIN ( '' +
					 ''  SELECT DISTINCT '' + @select + ''
						FROM '' + @view + '' WITH(NOLOCK) WHERE field like '''''' +  word  + ''%'''' '' +
						CASE WHEN @view2 IS NOT NULL THEN
							''
							UNION  
							SELECT DISTINCT '' + @select + ''
							FROM '' + @view2 + '' WITH(NOLOCK) WHERE field like '''''' +  word  + ''%'''' '' 
						ELSE  '''' END +
						CASE WHEN @view3 IS NOT NULL THEN
							''  
							UNION
							SELECT DISTINCT '' + @select + ''
							FROM '' + @view3 + '' WITH(NOLOCK) WHERE field like '''''' +  word  + ''%'''' '' 
						ELSE  '''' END +	
						CASE WHEN @view4 IS NOT NULL THEN
							''  
							UNION
							SELECT DISTINCT '' + @select + ''
							FROM '' + @view4 + '' WITH(NOLOCK) WHERE field like '''''' +  word  + ''%'''' '' 
						ELSE  '''' END + '' ) z''+ cast(@i as varchar(50)) + '' ON '' + @join + '' = z'' + cast(@i as varchar(50)) + ''.'' + @select 					
			FROM    @tmp_word
			WHERE   id = @i
		END  
				
	RETURN @string
END

' 
END

GO
