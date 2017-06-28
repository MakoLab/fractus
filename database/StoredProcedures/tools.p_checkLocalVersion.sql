/*
name=[tools].[p_checkLocalVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
o+ABrVH0sUxjmDy8jYeE6g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_checkLocalVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_checkLocalVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_checkLocalVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[p_checkLocalVersion]
@remoteVersion XML
AS

DECLARE @localVersion XML


DECLARE @tmp_local TABLE (typ varchar(50), name varchar(500), [_CHECKSUM] varchar(500))
DECLARE @tmp_remote TABLE (typ varchar(50), name varchar(500), [_CHECKSUM] varchar(500))
DECLARE @tmp_diffrent TABLE (typ varchar(50), name varchar(500), isLocal bit, isRemote bit, isDiff bit )

/*Pobieram wersję lokalną*/
SELECT @localVersion = tools.f_getObjectVersions()

/*Przepisuję dane o wersji lokalnej*/
INSERT INTO @tmp_local 
SELECT	x.value(''(typ)[1]'', ''varchar(500)'') ,
		x.value(''(name)[1]'', ''varchar(500)'') ,
		x.value(''(_CHECKSUM)[1]'', ''varchar(500)'') 
FROM  @localVersion.nodes(''root/entry'') AS a (x)


/*Przepisuję dane o wersji sprawdzanej*/
INSERT INTO @tmp_remote 
SELECT  x.value(''(typ)[1]'', ''varchar(500)'') ,
		x.value(''(name)[1]'', ''varchar(500)'') ,
		x.value(''(_CHECKSUM)[1]'', ''varchar(500)'') 
FROM  @remoteVersion.nodes(''root/entry'') AS a (x)

/*Porównania*/

INSERT INTO @tmp_diffrent 
SELECT l.typ ,l.name ,  1, CASE WHEN r.name IS NULL THEN 0 ELSE 1 END , 1
FROM @tmp_local l
	LEFT JOIN @tmp_remote r ON l.name = r.name
WHERE r.name IS NULL OR l._CHECKSUM <> r._CHECKSUM

INSERT INTO @tmp_diffrent 
SELECT l.typ, l.name , CASE WHEN r.name IS NULL THEN 0 ELSE 1 END , 1, 1
FROM @tmp_remote l
	LEFT JOIN @tmp_local r ON l.name = r.name
WHERE r.name IS NULL OR l._CHECKSUM <> r._CHECKSUM



SELECT DISTINCT * FROM @tmp_diffrent order by typ, name
' 
END
GO
