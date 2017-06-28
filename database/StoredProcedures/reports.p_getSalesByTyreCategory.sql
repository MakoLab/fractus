/*
name=[reports].[p_getSalesByTyreCategory]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
qe7pHXXEafjDg0JYffz28A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesByTyreCategory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getSalesByTyreCategory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getSalesByTyreCategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [reports].[p_getSalesByTyreCategory] --''<r/>''
	@xmlVar XML
as
select
(
select isnull(vehicle, '''') + '' - '' + isnull(season, '''') as category, sum(quantity) as ''quantity'', sum(net) as ''netValue'', sum(gross) as ''grossValue'' from
(
	select
		-l.commercialDirection * l.netValue as net,
		-l.commercialDirection * l.grossValue as gross,
		-l.commercialDirection * l.quantity as quantity,
		(
			select textValue
			from item.itemattrvalue v
			join dictionary.itemfield f on f.id = v.itemfieldid
			where f.name = ''Attribute_Season'' and v.itemid = i.id
		) season,
		(
			select textValue
			from item.itemattrvalue v
			join dictionary.itemfield f on f.id = v.itemfieldid
			where f.name = ''Attribute_VehicleType'' and v.itemid = i.id
		) vehicle
	from document.commercialdocumentline l
	join item.item i on i.id = l.itemid
	join document.commercialdocumentheader h on h.id = l.commercialdocumentheaderid
	join dictionary.documenttype dt on dt.id = h.documenttypeid
	where dt.documentcategory in (0,5) AND h.status >= 40
) line
group by season, vehicle
order by category asc
for xml auto, type
) for xml path (''root''), type' 
END
GO
