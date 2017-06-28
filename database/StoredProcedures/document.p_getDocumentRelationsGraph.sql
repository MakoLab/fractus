/*
name=[document].[p_getDocumentRelationsGraph]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
25ibl7+FznXBjK/UEy8CIw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentRelationsGraph]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDocumentRelationsGraph]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDocumentRelationsGraph]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getDocumentRelationsGraph]
@xmlVar XML
AS
BEGIN
	declare @nodes table (i int identity, id uniqueidentifier, type varchar(30), description varchar(100), date datetime, ordinalNumber int, documentTypeId uniqueidentifier, quantity float, direction int, documentId uniqueidentifier)
	declare @edges table (i int identity, id uniqueidentifier, type varchar(30), description varchar(100), id1 uniqueidentifier, id2 uniqueidentifier)

	declare @currentNode int, @currentEdge int, @currentDir int
	declare @currentNodeId uniqueidentifier, @currentEdgeId uniqueidentifier

	SELECT @currentNodeId = x.query(''lineId'').value(''.'',''char(36)'') FROM @xmlVar.nodes(''*'') AS a(x)

	set @currentNode = 1
	set @currentEdge = 1
	set @currentDir = 1

	while(@currentNodeId is not null)
	begin
		-- jezeli biezacego wezla jeszcze nie przetworzono
		if (not exists(select id from @nodes where id = @currentnodeid))
		begin
			-- wstaw wezel (pozycje dokumentu) do tabeli wezlow
			insert into @nodes (id, type, description, date, ordinalNumber, documentTypeId, quantity, direction, documentId)
			select * from (
				select WL.id, ''WarehouseDocument'' type, DT.symbol + '' '' + fullNumber + '' ['' + cast(cast(quantity as float) as varchar(100)) + '']'' description, WH.issueDate, WL.ordinalNumber, WH.documentTypeId, WL.quantity, WL.direction, WH.id documentId
					from document.WarehouseDocumentHeader WH
					join document.WarehouseDocumentLine WL on WL.warehousedocumentheaderid = WH.id
					join dictionary.DocumentType DT ON DT.id = WH.documentTypeId
					where WL.id = @currentNodeId
				union select CL.id, ''CommercialDocument'' type, DT.symbol + '' '' + fullNumber + '' ['' + cast(cast(quantity as float) as varchar(100)) + '']'' description, CH.issueDate, CL.ordinalNumber, CH.documentTypeId, CL.quantity, CL.commercialDirection + CL.orderDirection direction, CH.id documentId
					from document.CommercialDocumentHeader CH
					join document.CommercialDocumentLine CL ON CL.commercialdocumentheaderid = CH.id
					join dictionary.DocumentType DT ON DT.id = CH.documentTypeId
					where CL.id = @currentNodeId
				/*
				union select FL.id, ''FinancialDocument'' type, fullNumber, FH.issueDate, FL.ordinalNumber, FH.documentTypeId, FL.amount, FL.direction
					from document.FinancialDocumentHeader FH
					join finance.Payment FL on FL.financialdocumentheaderid = FH.id
					where FL.id = @currentNodeId
				*/
			) X

			-- wstaw wszystkie powiazania biezacego wezla do tabeli (za wyjatkiem tych ktore juz sa w tej tabeli)
			insert into @edges (id, type, description, id1, id2)
			select id, type, description, isnull(id1, id2), isnull(id2, id1) from (
				select id, ''IncomeOutcomeRelation'' type, cast(cast(quantity as float) as varchar(100)) description, incomeWarehouseDocumentLineId id1, outcomeWarehouseDocumentLineId id2
					from document.IncomeOutcomeRelation
					where incomeWarehouseDocumentLineId = @currentNodeId or outcomeWarehouseDocumentLineId = @currentNodeId
				union select id, ''WarehouseCommercialRelation'' type, cast(cast(quantity as float) as varchar(100)) description, warehouseDocumentLineId id1, commercialDocumentLineId id2
					from document.CommercialWarehouseRelation
					where warehouseDocumentLineId = @currentNodeId or commercialDocumentLineId = @currentNodeId
				union select id, ''WarehouseDocumentValuation'' type, cast(cast(quantity as float) as varchar(100)) + ''x'' + cast(cast(incomePrice as float) as varchar(100)) description, incomeWarehouseDocumentLineId id1, outcomeWarehouseDocumentLineId id2
					from document.WarehouseDocumentValuation
					where incomeWarehouseDocumentLineId = @currentNodeId or outcomeWarehouseDocumentLineId = @currentNodeId
				union select id, ''CommercialWarehouseValuation'' type, cast(cast(quantity as float) as varchar(100)) + ''x'' + cast(cast(price as float) as varchar(100)), warehouseDocumentLineId id1, commercialDocumentLineId id2
					from document.CommercialWarehouseValuation
					where warehouseDocumentLineId = @currentNodeId or commercialDocumentLineId = @currentNodeId
				union select id, ''WarehouseDocumentCorrection'' type, ''kor'', id id1, correctedWarehouseDocumentLineId id2
					from document.WarehouseDocumentLine
					where correctedWarehouseDocumentLineId is not null and (id = @currentNodeId or correctedWarehouseDocumentLineId = @currentNodeId)
				union select id, ''CommercialDocumentCorrection'' type, ''kor'', id id1, correctedCommercialDocumentLineId id2
					from document.CommercialDocumentLine
					where correctedCommercialDocumentLineId is not null and (id = @currentNodeId or correctedCommercialDocumentLineId = @currentNodeId)
				/*
				union select PS.id, ''PaymentSettlement'' type, cast(cast(PS.amount as float) as varchar(100)), isnull(P1.commercialDocumentHeaderId, P1.financialDocumentHeaderId) id1, isnull(P2.commercialDocumentHeaderId, P2.financialDocumentHeaderId) id2
					from finance.PaymentSettlement PS
					join finance.Payment P1 on P1.id = PS.incomePaymentId or P1.id = PS.outcomePaymentId
					join finance.Payment P2 on P2.id = PS.incomePaymentId or P2.id = PS.outcomePaymentId
					where isnull(P1.commercialDocumentHeaderId, P1.financialDocumentHeaderId) = @currentNodeId or isnull(P2.commercialDocumentHeaderId, P2.financialDocumentHeaderId) = @currentNodeId
				*/
			) X where X.id not in (select id from @edges)
		end

		-- pobierz drugie id z biezacej relacji lub przejdz do kolejnej relacji, petla zakonczy sie gdy wszystkie relacje zostana wyczerpane
		set @currentNodeId = NULL
		select @currentNodeId = case when @currentDir = 1 then id1 else id2 end from @edges where i = @currentEdge
		set @currentDir = @currentDir * -1
		if @currentDir = 1 set @currentEdge = @currentEdge + 1

	end

	declare @edges2 table (i int identity, description varchar(200), id1 uniqueidentifier, id2 uniqueidentifier)

	-- stworz tyle relacji ile jest unikalnych par wiazanych obiektow
	insert into @edges2 (id1, id2)
	select distinct id1, id2
	from @edges

	-- uzupelnij opisy w relacjach
	declare @i int
	set @i = 1
	declare @id1 uniqueidentifier, @id2 uniqueidentifier, @description varchar(100)
	while (1=1)
	begin
		select @id1 = null, @id2 = null
		select @id1 = id1, @id2 = id2, @description = description from @edges where i = @i
		if @id1 is null and @id2 is null break
		update @edges2 set description = isnull(description + ''; '', '''') + @description where (id1 = @id1 and id2 = @id2) or (id1 = @id2 and id2 = @id1)
		set @i = @i + 1
	end

	-- zwrot wyniku
	select (
		select id ''@id'', documentTypeId ''@documentTypeId'', description ''@name'', type ''@desc'', quantity ''@quantity'', direction ''@direction'', documentId ''@documentId''
			from @nodes order by date asc, case when type = ''WarehouseDocument'' then 0 else 1 end, ordinalNumber asc
			for xml path(''Node''), TYPE
		), (
		select isnull(id1, id2) ''@fromID'', isnull(id2, id1) ''@toID'', description ''@edgeLabel''--, 10 ''@flow''
			from @edges2
			for xml path(''Edge''), TYPE
	) for xml path (''Graph''), TYPE

	/*
		exec document.p_getDocumentRelationsGraph @xmlVar = ''<params><lineId>82C0567C-F658-4869-9407-747DD37F52C1</lineId></params>''
	*/
END
' 
END
GO
