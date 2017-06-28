/*
name=[tools].[p_createPzNaWszystkieTowary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
HYShcVOByXmUnDQACJfj1w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_createPzNaWszystkieTowary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_createPzNaWszystkieTowary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_createPzNaWszystkieTowary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [tools].[p_createPzNaWszystkieTowary]
as
declare 
@i int,
@nrdok int,
@count int,
@lp int,
@doc uniqueidentifier,
@data datetime


declare @tmp_item Table (i int identity(1,1), id uniqueidentifier)


insert into @tmp_item ( id )
select  id from item.Item 
select @count = @@rowcount



SELECT @i = 1, @nrdok = 0

WHILE @i <= @count
	BEGIN
		
	IF (@i % 100 = 0) OR (@i = 1) 
		BEGIN
			SELECT @doc = newid(),@nrdok = @nrdok + 1, @lp = 1, @data = getdate()
			print ''wstawienie naglowka''
			INSERT INTO [document].[WarehouseDocumentHeader]
				   ([id],						[documentTypeId],						 [contractorId],						[warehouseId],					[documentCurrencyId],					[systemCurrencyId], [number],								[fullNumber],[issueDate],[value],							[seriesId],[modificationDate],[modificationApplicationUserId],[version], [status], [branchId], [companyId])
			SELECT	@doc, ''CE3CBCD2-4636-402C-9A2F-DF0EB6191B3C'',''FAFE7086-230F-4F39-913C-0000BFFBEA27'',''A4CCB6BE-ED7F-4B39-8F6F-7A492D71CD45'',''F01007BF-1ADA-4218-AE77-52C106DA4105'',''F01007BF-1ADA-4218-AE77-52C106DA4105'',@nrdok , CAST(@nrdok as varchar(50)) + ''/PZ/4/2009/'',@data     , 10000, ''0666B3F1-A8CF-4026-BEE1-AF0A0925B1B9'', getdate(),null, newid(), 40,''0E11C84C-E433-4E3D-8B5F-CF140F16A97B'',''26F958D1-06D7-4CDB-8002-9205F5871BE3''

		END

	INSERT INTO [document].[WarehouseDocumentLine]
           ([id],  [warehouseDocumentHeaderId],[direction],[itemId],[warehouseId],[unitId],[quantity],[price],[value],[incomeDate],[outcomeDate],[description],[ordinalNumber],[version],isDistributed)
	SELECT newid(), @doc,                      1,               id,''A4CCB6BE-ED7F-4B39-8F6F-7A492D71CD45'',''2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C'',50000,10,500000,@data, null,null,@lp,newid(), 0
	FROM @tmp_item i
	WHERE i = @i

	SELECT @i = @i + 1 , @lp = @lp + 1
	
END
	
		INSERT INTO document.CommercialWarehouseValuation (id, commercialDocumentLineId,warehouseDocumentLineId, quantity,[value], price, version )
		SELECT newid(), NULL, id, quantity,[value], 5000 , newid() 
		FROM [document].[WarehouseDocumentLine] 
		WHERE id not in (select warehouseDocumentLineId FROM document.CommercialWarehouseValuation )
' 
END
GO
