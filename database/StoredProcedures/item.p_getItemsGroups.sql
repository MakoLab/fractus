/*
name=[item].[p_getItemsGroups]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8jZyFPjXBPARKIIj4qpgjA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsGroups]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE item.p_getItemsGroups
 @xmlVar XML
 AS
 BEGIN
	 DECLARE @tmp TABLE (itemId char(36))
	 INSERT INTO @tmp
	 SELECT x.value(''@id[1]'',''char(36)'')
	 FROM @xmlVar.nodes(''root/item'') a(x)
	 
	 SELECT (
		 SELECT itemId AS ''@id'', CAST((	SELECT itemGroupId 
									FROM item.ItemGroupMembership 
									WHERE itemId = t.itemId 
									FOR XML PATH(''''), TYPE ) AS xml)
		FROM @tmp t	
		FOR XML PATH(''item''), TYPE	
	) FOR XML PATH(''root''), TYPE						
 END
 ' 
END
GO
