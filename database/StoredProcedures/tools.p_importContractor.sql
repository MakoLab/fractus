/*
name=[tools].[p_importContractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/uwpKbFjl/j0qJKhxRFuhA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_importContractor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_importContractor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_importContractor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 
CREATE PROCEDURE [tools].[p_importContractor]

AS
begin

declare @contractorId uniqueidentifier , @i int, @contractorAddresId uniqueidentifier, @idd varchar(500)

 

declare op cursor for
SELECT  k.id 
FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k 
LEFT JOIN [translation].Kontrahent t ON CAST(k.idMM as varchar(50)) = CAST(t.megaId  as varchar(50)) 
WHERE t.id IS NULL
OPEN op
FETCH NEXT FROM op INTO @i
WHILE @@FETCH_STATUS = 0
       BEGIN
			select @idd = CAST(@i as varchar(500))
			print @idd
             exec tools.[p_dodajKontrahenta]  @i, @contractorId OUTPUT ,@contractorAddresId OUTPUT
             FETCH NEXT FROM op INTO @i
       END
CLOSE op DEALLOCATE op
end
' 
END
GO
