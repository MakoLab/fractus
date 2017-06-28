/*
name=[tools].[p_compareProceduresByHash]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
I3iXdunfvOJukzqs15/HhQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_compareProceduresByHash]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_compareProceduresByHash]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_compareProceduresByHash]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE  PROCEDURE [tools].[p_compareProceduresByHash] 
@xml1 XML = NULL, 
@xml2 XML = NULL
AS
BEGIN
/* Jeśli w parametrach wywołania procedury podano dwa XMLe zostaną one porównane, 
a procedury, które posiadaja różne hashe zostaną zwrócone jako wynik */
	IF @xml1 IS NOT NULL AND @xml2 IS NOT NULL
		BEGIN
			DECLARE @Test1 TABLE (
									name VARCHAR(MAX), 
									code VARCHAR(MAX)
								)
			DECLARE @Test2 TABLE (
									name VARCHAR(MAX), 
									code VARCHAR(MAX)
								)
								
			INSERT INTO @Test1
			SELECT  x.value(''@nazwa'',''VARCHAR(MAX)''), x.value(''@hash'',''VARCHAR(MAX)'')
			FROM @xml1.nodes(''root/procedura'') as a (x)
								
			INSERT INTO @Test2
			SELECT  x.value(''@nazwa'',''VARCHAR(MAX)''), x.value(''@hash'',''VARCHAR(MAX)'')
			FROM @xml2.nodes(''root/procedura'') as a (x)
			
			SELECT ISNULL(t1.name, t2.name)
			FROM @Test1 t1
			FULL JOIN @Test2 t2 ON t1.name = t2.name
			WHERE ISNULL(t1.code,'''') <> ISNULL(t2.code,'''')
			ORDER BY 1
		
		END
/* Procedura wywołana bez parametrów zwróci jako wynik XML z hashami procedur i ich nazwami */		
	ELSE
		BEGIN
			DECLARE @Test TABLE (
									Id INT IDENTITY(1,1),
									name VARCHAR(MAX), 
									Code VARCHAR(MAX)
								)
			DECLARE @lnCurrent INT, @lnMax INT
			DECLARE @LongName VARCHAR(MAX), @hash VARCHAR(MAX)

			INSERT INTO @Test (name,Code)
			SELECT s.name + ''.'' + p.name, 
			replace(replace(replace(OBJECT_DEFINITION(p.OBJECT_ID),'' '',''''),CHAR(13),''''),CHAR(10),'''') +  --usuneicie bialych zankow
			CHAR(13) + CHAR(10) + ''GO'' + CHAR(13) + CHAR(10)
			FROM sys.procedures p
			LEFT JOIN sys.schemas s ON p.schema_id = s.schema_id
			WHERE p.is_ms_shipped = 0
			ORDER BY 1

			SET @hash = ''''
			SELECT @lnMax = MAX(Id) FROM @Test
			SET @lnCurrent = 1
			WHILE @lnCurrent <= @lnMax
			
			/* Ponieważ hashowac można tylko do 8000 znaków, dłuższe procedury są hashowanepo 8k znaków,
			a następnie jest tworzony hash ze złożenia tych hashy :) */
			BEGIN
				SELECT @LongName = Code FROM @Test WHERE Id = @lnCurrent
				IF LEN(@LongName) > 8000
				BEGIN
					WHILE @LongName <> ''''
					BEGIN
						SET @hash = @hash + CAST(HashBytes(''MD5'', LEFT(@LongName, 8000)) AS VARCHAR(max))
						SET @LongName = SUBSTRING(@LongName, 8001, LEN(@LongName))
					END
					UPDATE @Test SET Code = @hash WHERE Id = @lnCurrent
					SET @hash = ''''
				END
				SET @lnCurrent = @lnCurrent + 1
			END
			      
			SELECT ( 
				SELECT name ''@nazwa'', HashBytes(''MD5'', LEFT(code, 8000)) ''@hash'' FROM @test
				FOR XML PATH(''procedura''), TYPE )
			FOR XML PATH(''root''), TYPE
		END
END

' 
END
GO
