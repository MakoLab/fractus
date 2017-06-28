/*
name=[dbo].[zmiana]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xrOCoMLf2fFHBzV/ZvIHuw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zmiana]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[zmiana]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zmiana]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'  create procedure zmiana
  @tmpDzien datetime,
  @tmpCos bit
  as
	begin
	--declare
	update praktyki 
	set [cos]=@tmpCos
	where dzien=@tmpDzien
end
' 
END
GO
