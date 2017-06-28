/*
name=[tools].[p_updateItemDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SeJT+vEZYg5CoEtRNT0S7A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_updateItemDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_updateItemDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_updateItemDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[p_updateItemDictionary]
As
DECLARE @i int , @rows int , @a varchar(500), @FLAG int


SELECT @rows  = COUNT(id)+  MIN(i), @i = MIN(i) FROM tmp_items 


WHILE @i <= @rows

	BEGIN
		SELECT  @a =  ''<root businessObjectId="''+ id +''"/>'' FROM tmp_items WHERE i = @i
		
		BEGIN TRY
			BEGIN TRANSACTION	
			
			EXEC [item].[p_updateItemDictionary] @a
			SET @FLAG = 1
			DELETE FROM tmp_items WHERE i = @i
			
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			
			ROLLBACK TRAN
			SET @FLAG = 0
			WAITFOR DELAY ''00:00:05''
		END CATCH
					
		SELECT @i = @i + @FLAG
	END
' 
END
GO
