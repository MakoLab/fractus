/*
name=[dbo].[KwotaSlownie]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hFbKr5Z+riaD6XWvpy3SQg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KwotaSlownie]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[KwotaSlownie]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[KwotaSlownie]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[KwotaSlownie](@wartosc int)
RETURNS nvarchar(200)
AS
BEGIN
IF @wartosc = 0
  RETURN ''zero''
  
DECLARE @jednosc int = @wartosc % 10
DECLARE @para int = @wartosc % 100
DECLARE @set int = (@wartosc % 1000) / 100;

DECLARE @result nvarchar(200) = ''''
IF (@para >= 10 AND @para < 20)
  SET @result =
    (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''N'' AND Value=@jednosc)
ELSE
BEGIN
  SET @result =
    (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''D'' AND Value=(@para/10))
    + (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''J'' AND Value=@jednosc)
END
SET @result =
  (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''S'' AND Value=@set)
+  @result


DECLARE @mult char(1)=''0''
SET @wartosc = @wartosc / 1000;
WHILE @wartosc>0
BEGIN
  SET @jednosc = @wartosc % 10;
  SET @para = @wartosc % 100;
  SET @set = (@wartosc % 1000) / 100;
  
  IF ((@wartosc % 1000) / 10 = 0)
  BEGIN
    SET @result =
      CASE WHEN @jednosc > 1 THEN
        (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''J'' AND Value=@jednosc)
      ELSE ''''
      END
    + CASE WHEN @jednosc=1 THEN
        (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=@mult AND Value=1)
      WHEN @jednosc BETWEEN 2 AND 4 THEN
        (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=@mult AND Value=2)
      WHEN @wartosc % 1000 != 0 THEN
        (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=@mult AND Value=5)
	  ELSE ''''
      END
    + @result
  END
  ELSE IF (@para >= 10 AND @para < 20)
  BEGIN
    SET @result =
      (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''N'' AND Value=@para%10)
    + (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=@mult AND Value=5)
    + @result
  END
  ELSE
  BEGIN
    SET @result =
      (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''D'' AND Value=(@para/10))
    + (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''J'' AND Value=@jednosc)
    + CASE WHEN @jednosc BETWEEN 2 AND 4 THEN
        (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=@mult AND Value=2)
      ELSE
        (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=@mult AND Value=5)
      END
    + @result
  END
  SET @result =
    (SELECT TOP 1 Liczebnik FROM Liczebniki WHERE Rzad=''S'' AND Value=@set)
  +  @result
  SET @wartosc = @wartosc / 1000
  SET @mult = @mult+1
END
RETURN RTRIM(LTRIM(REPLACE(@result,''  '', '' '')))
END' 
END

GO
