/*
name=[tools].[p_compareTablesByColumns]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
g964n/Gp1XFTU3c9puY4Tw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_compareTablesByColumns]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_compareTablesByColumns]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_compareTablesByColumns]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [tools].[p_compareTablesByColumns] 
@xml1 XML = NULL, 
@xml2 XML = NULL
AS
BEGIN
/* Jeśli w parametrach wywołania procedury podano dwa XMLe zostaną one porównane, 
a tabele, które posiadaja różne kolumny zostaną zwrócone jako wynik */
	IF @xml1 IS NOT NULL AND @xml2 IS NOT NULL
		BEGIN
			DECLARE @Test1 TABLE (
									tableName VARCHAR(MAX), 
									columnName VARCHAR(MAX),
									columnNo INT
								)
			DECLARE @Test2 TABLE (
									tableName VARCHAR(MAX), 
									columnName VARCHAR(MAX),
									columnNo INT
								)
								
			INSERT INTO @Test1
			SELECT  x.value(''@nazwaTabeli'',''VARCHAR(MAX)''), x.value(''@nazwaKolumny'',''VARCHAR(MAX)''), x.value(''@Lp'',''INT'')
			FROM @xml1.nodes(''root/kolumna'') as a (x)
								
			INSERT INTO @Test2
			SELECT  x.value(''@nazwaTabeli'',''VARCHAR(MAX)''), x.value(''@nazwaKolumny'',''VARCHAR(MAX)''), x.value(''@Lp'',''INT'')
			FROM @xml2.nodes(''root/kolumna'') as a (x)
			
			SELECT *
			FROM @Test1 t1
			FULL JOIN @Test2 t2 ON t1.tableName = t2.tableName AND t1.columnNo = t2.columnNo
			WHERE t1.columnNo IS NULL OR t2.columnNo IS NULL OR ISNULL(t1.columnName,'''') <> ISNULL(t2.columnName,'''')
			ORDER BY 1
		
		END
/* Procedura wywołana bez parametrów zwróci jako wynik XML z tabelami i ich kolumnami */		
	ELSE
		BEGIN
			DECLARE @Test TABLE (
									tableName VARCHAR(MAX), 
									columnName VARCHAR(MAX),
									columnNo INT
								)

			INSERT INTO @Test
			SELECT s.name+''.''+t.name, c.name, c.column_id 
			FROM sys.tables t
			LEFT JOIN sys.schemas s ON t.schema_id = s.schema_id
			LEFT JOIN sys.columns c ON t.object_id = c.object_id
			ORDER BY 1, 3
			      
			SELECT ( 
				SELECT tableName ''@nazwaTabeli'', columnName ''@nazwaKolumny'', columnNo ''@Lp'' FROM @test
				FOR XML PATH(''kolumna''), TYPE )
			FOR XML PATH(''root''), TYPE
		END
END
' 
END
GO
