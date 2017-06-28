/*
name=[item].[p_getItemsForDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
RG2bGfwYOVUiyqs20Pe9HA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsForDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsForDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsForDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_getItemsForDocument]
	@xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @returnXML XML

		/*Budowanie XML z danycmi o powiązaniach towaru*/
		SELECT @returnXML = (   				
						SELECT	id as ''@id'',
								vatRateId as ''@vatRateId'',
								version as ''@version'',
								defaultPrice as ''@netPrice'',
								unitId as ''@unitId'',
								code as ''@code''

						FROM	item.Item 
								JOIN @xmlVar.nodes(''root/item'') as a(x) ON Item.id = x.value(''@id'',''char(36)'')
						FOR XML PATH(''item''), TYPE
						)

		/*Zwrócenie wyników*/
        SELECT  @returnXML
        FOR     XML PATH(''root''),
                    TYPE
    END
' 
END
GO
