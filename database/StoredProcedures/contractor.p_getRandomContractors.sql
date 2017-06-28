/*
name=[contractor].[p_getRandomContractors]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0Jq2gbLmixBgWvOj25YKVA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getRandomContractors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getRandomContractors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getRandomContractors]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getRandomContractors]
@xmlVar XML
AS
DECLARE
@s int 
,@g int
,@i int
,@x int
,@id uniqueidentifier

DECLARE  @tmp_t TABLE (id uniqueidentifier)

/*Pobranie ilości oczekiwanych linii*/
SELECT @s = NULLIF(x.value(''@amount[1]'',''int''),0)
FROM @xmlVar.nodes(''/*'') a ( x )

SELECT TOP 1 @id =id , @x = 0, @g = 1 + CAST(RIGHT(CAST(DATEPART(s,getdate()) as varchar(2)),1) as int), @i = 1
FROM contractor.Contractor  WITH(NOLOCK)
ORDER BY id

WHILE (@x + 1) <= @s 
	BEGIN

		SELECT TOP 1 @id = id
		FROM contractor.Contractor WITH(NOLOCK)
		WHERE id > @id
		ORDER BY id

		IF @i%@g = 0 
			BEGIN
				SELECT @x = @x + 1 
				INSERT INTO @tmp_t SELECT @id
			END
			
		SELECT @i = @i + 1
	END
SELECT (
	SELECT id 
	FROM @tmp_t contractor  
	FOR XML AUTO, TYPE
) FOR XML PATH(''root''), TYPE
' 
END
GO
