/*
name=[tools].[p_compareBussinesObjectVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uE+xflI3vDE30PiGST1CFA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_compareBussinesObjectVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_compareBussinesObjectVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_compareBussinesObjectVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE tools.p_compareBussinesObjectVersion @xmlVar xml
as
BEGIN
	DECLARE @localXml xml,@branchId uniqueidentifier
	CREATE TABLE #tmpLocal  ([typ] varchar(50), id uniqueidentifier NOT NULL,[modificationDate] datetime, symbol varchar(50),[version] uniqueidentifier,  _CHECKSUM nvarchar(30) )
	CREATE TABLE #tmpRemote ([typ] varchar(50), id uniqueidentifier NOT NULL,[modificationDate] datetime, symbol varchar(50),[version] uniqueidentifier,  _CHECKSUM nvarchar(30) )



	ALTER TABLE #tmpLocal ADD  CONSTRAINT [tmpPK_localId] PRIMARY KEY CLUSTERED  ( [id] ASC )
	ALTER TABLE #tmpRemote ADD  CONSTRAINT [tmpPK_remoteId] PRIMARY KEY CLUSTERED  ( [id] ASC )

	CREATE NONCLUSTERED INDEX ind_local ON #tmpLocal ( typ ASC , _CHECKSUM ASC)
	CREATE NONCLUSTERED INDEX ind_remote ON #tmpRemote ( typ ASC , _CHECKSUM ASC)


	SELECT @branchId = @xmlVar.value(''(root/root/@branchId)[1]'',''char(36)'')
	--SELECT @branchId
	INSERT INTO #tmpRemote
	SELECT	x.value(''(@typ)[1]'',''varchar(50)''),
			x.value(''(@id)[1]'',''char(36)''),
			x.value(''(@modificationDate)[1]'',''varchar(50)''),
			x.value(''(@symbol)[1]'',''varchar(50)''),
			x.value(''(@version)[1]'',''char(36)''),
			x.value(''(@_CHECKSUM)[1]'',''varchar(30)'')
	FROM @xmlVar.nodes(''root/root/object'') as a(x)


	EXEC tools.p_createBussinesObjectVersion  @xmlVar = @xmlVar OUT, @branchId = @branchId

	INSERT INTO #tmpLocal
	SELECT	x.value(''(@typ)[1]'',''varchar(50)''),
			x.value(''(@id)[1]'',''char(36)''),
			x.value(''(@modificationDate)[1]'',''varchar(50)''),
			x.value(''(@symbol)[1]'',''varchar(50)''),
			x.value(''(@version)[1]'',''char(36)''),
			x.value(''(@_CHECKSUM)[1]'',''varchar(30)'')
	FROM @xmlVar.nodes(''root/root/object'') as a(x)


	SELECT l.typ,l.symbol, l.id, l.[modificationDate] ,r.[modificationDate] , l.[version] , r.[version]
	FROM #tmpLocal l
		LEFT JOIN #tmpRemote r ON l.typ = r.typ AND l.id = r.id --AND l.branchId = r.branchId
	WHERE  ISNULL(l._CHECKSUM,'''') <> ISNULL(r._CHECKSUM,'''') AND l.symbol NOT LIKE ''MM%''

END
' 
END
GO
