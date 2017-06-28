/*
name=[dbo].[test1]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ikcD6+hkBlBa0T3w4hjqTA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[test1]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[test1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[test1]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure test1 
as 
	begin

	declare
	@result XML
	         select  @result = (
						select * from test  for xml path(''root''), type)
		
        select  @result
        for    xml path(''root''),
                    type
   end
' 
END
GO
