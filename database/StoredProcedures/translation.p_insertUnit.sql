/*
name=[translation].[p_insertUnit]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fzMr3qoJ4s8MFsUAeToddw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertUnit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertUnit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertUnit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertUnit] @serverName VARCHAR(50), @dbName VARCHAR(50) AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@skrot VARCHAR(5),
			@counter NUMERIC,
			@query NVARCHAR(300)
	
	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa, skrot FROM [''+@serverName+''].''+@dbName+''.dbo.Slow_Jm''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa, @skrot
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = MAX([order]) + 1 FROM dictionary.Unit
		UPDATE dictionary.Unit
		SET xmlLabels = (SELECT
					(SELECT ''pl'' as ''@lang'', @skrot as ''@symbol'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE)
		WHERE xmlLabels.value(''(//labels/label/@symbol)[1]'', ''nvarchar(50)'') = @skrot
		IF NOT EXISTS(SELECT * FROM dictionary.Unit WHERE xmlLabels.value(''(//labels/label/@symbol)[1]'', ''nvarchar(50)'') = @skrot)
			INSERT INTO dictionary.Unit([id],[unitTypeId], [conversionRate], [xmlLabels], [version], [order])
			SELECT	
				NEWID(),
				(SELECT 
					CASE 
						WHEN @skrot=''szt.'' THEN (SELECT id FROM dictionary.UnitType WHERE [name] = ''Quantity_Unit'')
						WHEN @skrot=''kg'' THEN (SELECT id FROM dictionary.UnitType WHERE [name] = ''Weight_Unit'')
						WHEN @skrot=''l'' THEN (SELECT id FROM dictionary.UnitType WHERE [name] = ''Volume_Unit'')
						WHEN @skrot=''h'' THEN (SELECT id FROM dictionary.UnitType WHERE [name] = ''Time_Unit'')
						WHEN @skrot=''m2'' THEN (SELECT id FROM dictionary.UnitType WHERE [name] = ''Quantity_Unit'')
						WHEN @skrot=''mies.'' THEN (SELECT id FROM dictionary.UnitType WHERE [name] = ''TimeSpan_Unit'')
						ELSE (SELECT id FROM dictionary.UnitType WHERE [name] = ''Quantity_Unit'') 
					END
				) as [unitTypeId],
				(SELECT 1) as [conversionRate],
				(SELECT
					(SELECT ''pl'' as ''@lang'', @skrot as ''@symbol'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE) as [xmlLabels],
				NEWID(),
				(SELECT @counter) as [order]			
		FETCH FROM c INTO @nazwa, @skrot
	END
	CLOSE c
	DEALLOCATE c
END
' 
END
GO
