/*
name=[item].[p_getItemData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xk9yIABQW2q4HpGM4p1x+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 

CREATE PROCEDURE [item].[p_getItemData]--  ''D0CF4E1C-7877-4DA5-8EDB-36BA75F0D921''
    @itemId UNIQUEIDENTIFIER
AS
    BEGIN
        DECLARE @returnsXML XML,
            @relatedObjectId UNIQUEIDENTIFIER,
            @itemRelationTypeId UNIQUEIDENTIFIER,
            @count INT,
            @metaData XML,
            @SELECT VARCHAR(MAX),
            @object VARCHAR(50),
            @relatedObjectType VARCHAR(50)


        SELECT  @SELECT = ''	
		DECLARE  @xx xml 
		SELECT @xx = xmlValue from configuration.Configuration where [key] like ''''items.group''''
		SELECT     (SELECT (SELECT i.*
		FROM item.Item i WHERE i.id IN ( '''''' + CAST(@itemId AS CHAR(36)) + '''''' ''

		/*Specjalne traktowanie relacji z inymi towarami*/
        SELECT  @SELECT = @SELECT + '' , '''''' + x.relatedObjectId + ''''''''
        FROM    ( SELECT    xmlMetadata.query(''metadata/tableName'').value(''.'', ''varchar(50)'') object,
                            xmlMetadata.query(''metadata/relatedObjectType'').value(''.'', ''varchar(50)'') relatedObjectType,
                            CAST(relatedObjectId AS CHAR(36)) relatedObjectId
                  FROM      item.ItemRelation iur
                            JOIN dictionary.ItemRelationType itr ON iur.itemRelationTypeId = itr.id
                  WHERE     xmlMetadata.query(''metadata/tableName'').value(''.'', ''varchar(50)'') = ''item.Item''
                ) x


        SELECT  @SELECT = @SELECT
                + '' ) FOR XML PATH(''''entry''''), TYPE) FOR XML PATH(''''item''''),TYPE),
	(SELECT (SELECT * FROM item.ItemUnitRelation WHERE itemId = ''''''
                + CAST(@itemId AS CHAR(36))
                + '''''' FOR XML PATH(''''entry''''), TYPE) FOR XML PATH(''''itemUnitRelation''''),TYPE),
	(SELECT (SELECT * FROM item.ItemRelation WHERE itemId = ''''''
                + CAST(@itemId AS CHAR(36))
                + ''''''  FOR XML PATH(''''entry''''), TYPE  ) FOR XML PATH(''''itemRelation''''),TYPE),
    (SELECT (SELECT * FROM item.ItemAddress WHERE itemId = ''''''
                + CAST(@itemId AS CHAR(36))
                + ''''''  FOR XML PATH(''''entry''''), TYPE  ) FOR XML PATH(''''itemAddress''''),TYPE),
	(SELECT (SELECT * FROM item.ItemRelationAttrValue WHERE itemRelationId = (SELECT top 1 ir.id FROM item.ItemRelation ir WHERE ir.itemId = ''''''
                + CAST(@itemId AS CHAR(36))
                + '''''') FOR XML PATH(''''entry''''), TYPE) FOR XML PATH(''''itemRelationAttrValue''''),TYPE ),
	(SELECT (
			SELECT * 
			FROM (
				SELECT id, itemId, itemFieldId, decimalValue, dateValue, textValue,  [version], [order] FROM item.ItemAttrValue WHERE itemId = '''''' + CAST(@itemId AS CHAR(36)) + '''''' 
			UNION
			
				SELECT newid() id, '''''' + CAST(@itemId AS CHAR(36)) + '''''' itemId, (select id from dictionary.ItemField where name like ''''Attribute_ItemGroup'''')  itemFieldId, null decimalValue, null dateValue, 
						(SELECT TOP 1  replace( [dbo].[f_getGroupLabel_tree](fg.itemGroupId  ,@xx, '''' -> ''''), ''''Grupy towarowe -> '''', '''''''' ) from item.ItemGroupMembership fg WHERE fg.itemId =  '''''' + CAST(@itemId AS CHAR(36)) + '''''' ) textValue,   newid() [version], 101 [order]
				 ) x
			FOR XML PATH(''''entry''''), TYPE) FOR XML PATH(''''itemAttrValue''''), TYPE),''
                + '' (SELECT (SELECT * FROM item.ItemGroupMembership WHERE itemId = ''''''
                + CAST(@itemId AS CHAR(36))
                + '''''' FOR XML PATH(''''entry''''), TYPE) FOR XML PATH(''''itemGroupMembership''''),TYPE), ''
                
                
                

        SELECT  @SELECT = @SELECT + '',(SELECT(SELECT * FROM '' + x.object
                + '' WHERE id = '''''' + x.relatedObjectId
                + '''''' FOR XML PATH(''''entry''''),TYPE) FOR XML PATH(''''''
                + LOWER(LEFT(x.relatedObjectType, 1))
                + RIGHT(x.relatedObjectType, LEN(x.relatedObjectType) - 1)
                + ''''''), TYPE), ''
        FROM    ( SELECT DISTINCT
                            xmlMetadata.query(''metadata/tableName'').value(''.'', ''varchar(50)'') object,
                            xmlMetadata.query(''metadata/relatedObjectType'').value(''.'', ''varchar(50)'') relatedObjectType,
                            CAST(relatedObjectId AS CHAR(36)) relatedObjectId
                  FROM      item.ItemRelation iur
                            JOIN dictionary.ItemRelationType itr ON iur.itemRelationTypeId = itr.id
                  WHERE     xmlMetadata.query(''metadata/tableName'').value(''.'', ''varchar(50)'') = ''contractor.Contractor''
                            AND xmlMetadata.query(''metadata/tableName'').value(''.'', ''varchar(50)'') <> ''''
                            AND itemId = @itemId
                ) x
		SELECT  @SELECT = REPLACE(@SELECT , '', ,'','','')
        SELECT  @SELECT = LEFT(@SELECT, LEN(@SELECT) - 1)
                + ''  FOR XML PATH(''''root''''), TYPE ''
PRINT @SELECT
EXECUTE ( @SELECT               )
--select @select 
    END


 ' 
END
GO
