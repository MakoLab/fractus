/*
name=[custom].[v_salesByTireAttributes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/pZ7hqbxNrDJtDWJFqhHXw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[v_salesByTireAttributes]'))
DROP VIEW [custom].[v_salesByTireAttributes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[v_salesByTireAttributes]'))
EXEC dbo.sp_executesql @statement = N'CREATE view custom.v_salesByTireAttributes
as
select top 65536
	convert(char(10), ch.issueDate, 21) [Data],
	convert(char(7), ch.issueDate, 21) [Miesiąc],
	i.name [Nazwa],
	b.symbol [Oddział],
	sum(-cl.commercialDirection * cl.quantity) [Ilość],
	sum(-cl.commercialDirection * cl.netValue) [Wartość netto],
	sum(-cl.commercialDirection * cl.grossValue) [Wartość brutto],
	itl.label [Typ asortymentu],
	season.textValue as [Sezon],
	manufacturer.textValue as [Producent],
	vehicleType.textValue as [Rodzaj pojazdu]
from item.Item i
join document.CommercialDocumentLine cl on cl.itemId = i.id
join document.commercialdocumentheader ch on ch.id = cl.commercialDocumentHeaderId
join dictionary.Branch b on b.id = ch.branchId
join dictionary.DocumentType dt on dt.id = ch.documentTypeId
join custom.ItemTypeLabel itl on itl.id = i.itemTypeId
left join (
	select v.itemId, v.textValue
	from item.ItemAttrValue v
	join dictionary.ItemField f on f.id = v.itemFieldId and f.name = ''Attribute_Season''
) season on season.itemId = i.id
left join (
	select v.itemId, v.textValue
	from item.ItemAttrValue v
	join dictionary.ItemField f on f.id = v.itemFieldId and f.name = ''Attribute_Manufacturer''
) manufacturer on manufacturer.itemId = i.id
left join (
	select v.itemId, v.textValue
	from item.ItemAttrValue v
	join dictionary.ItemField f on f.id = v.itemFieldId and f.name = ''Attribute_VehicleType''
) vehicleType on vehicleType.itemId = i.id
where
	dt.documentCategory in (0,5)
	and ch.status >= 40
group by
	i.id, i.name, b.symbol,
	itl.label,
	season.textValue,
	manufacturer.textValue,
	vehicleType.textValue,
	convert(char(10), ch.issueDate, 21),
	convert(char(7), ch.issueDate, 21)
order by convert(char(10), ch.issueDate, 21) desc

/*
select id, xmlLabels.value(''(/labels/label)[1]'', ''varchar(100)'') label
into custom.ItemTypeLabel
from dictionary.ItemType
*/' 
GO
