/*
name=[dbo].[proc1]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FGMePDUcflXpjvJOoI4QCA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc1]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[proc1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc1]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure proc1 
@param int=0
as
	begin
	declare
	@wynik xml
		--select  @wynik = (
		select * from widokk where dzien = @param or @param=0
		 -- for xml path(''praktyki''), type)
		--select  @wynik for xml path(''dokument''), type
   end
' 
END
GO
