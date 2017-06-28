/*
name=[custom].[v_PriceRuleLak]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5Vs2F9uO0wVORYYoIzv0xw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[v_PriceRuleLak]'))
DROP VIEW [custom].[v_PriceRuleLak]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[custom].[v_PriceRuleLak]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [custom].[v_PriceRuleLak]
AS
SELECT        Id,
                             (SELECT        Tab.Col.value(''(condition/value)[1]'', ''varchar(500)'') AS Id
                               FROM            definition.nodes(''/root/conditions'') AS Tab(Col) CROSS APPLY Tab.Col.nodes(''condition'') AS Tab1(Col1)
                               WHERE        Tab1.Col1.value(''@name'', ''varchar(500)'') = ''itemGroups'') AS ItemGroupId,
                             (SELECT        CAST(Tab.Col.value(''(action/value)[1]'', ''varchar(500)'') AS DECIMAL(18, 2)) AS Discount
                               FROM            definition.nodes(''/root/actions'') AS Tab(Col) CROSS APPLY Tab.Col.nodes(''action'') AS Tab1(Col1)
                               WHERE        Tab1.Col1.value(''@name'', ''varchar(500)'') = ''discoutRateValue'') AS Discount
FROM            item.PriceRule

' 
GO
