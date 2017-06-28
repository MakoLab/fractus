/*
name=[translation].[p_insertWarehouseStock]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Pi3fUCN2u36qXv5d7Nd1GA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertWarehouseStock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertWarehouseStock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertWarehouseStock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertWarehouseStock] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @ilosc NUMERIC,
		@ilosc_rez NUMERIC,
		@idMM VARCHAR(50),
		@kod VARCHAR(10),
		@counter NUMERIC,
		@query NVARCHAR(500)

	DELETE FROM document.WarehouseStock	
	SELECT @counter = 0
	
	SELECT @query = ''DECLARE c CURSOR FOR SELECT TM.ilosc, TM.ilosc_rez, T.idMM, TMD.kod FROM [''+@serverName+''].''+@dbName+''.dbo.Tow_Magazyny TM INNER JOIN [''+@serverName+''].''+@dbName+''.dbo.Tow_MagazynyDef TMD ON TM.id_magazynu = TMD.id INNER JOIN [''+@serverName+''].''+@dbName+''.dbo.Towary T ON TM.id_towaru = T.id WHERE TM.ilosc <> 0 AND TMD.id IN (SELECT id_magazynu FROM [''+@serverName+''].''+@dbName+''.dbo.Oddzial_magazyn WHERE id_oddzialu IN (SELECT id_oddzialu FROM [''+@serverName+''].''+@dbName+''.dbo.Punkty ))''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @ilosc, @ilosc_rez, @idMM, @kod
	WHILE (@@fetch_status = 0)
	BEGIN
		INSERT INTO document.WarehouseStock (id, warehouseId, itemId, unitId, quantity, reservedQuantity, orderedQuantity)
		SELECT newid(),
			(SELECT id FROM dictionary.Warehouse WHERE rtrim(ltrim(symbol)) = ltrim(rtrim(@kod))),
			(SELECT fractus2Id FROM translation.Towary WHERE megaId = @idMM),
			(SELECT TOP 1 id FROM dictionary.Unit),
			@ilosc,
			@ilosc_rez,
			0
		FETCH FROM c INTO @ilosc, @ilosc_rez, @idMM, @kod
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO
