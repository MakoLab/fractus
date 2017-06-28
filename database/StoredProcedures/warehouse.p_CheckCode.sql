/*
name=[warehouse].[p_CheckCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2F1YVqwrYCnIbrzMxyuezg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_CheckCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_CheckCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_CheckCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_CheckCode]
	@code varchar(100)
AS
	/*Procedura sprawdza przekazany kod, próbuje znaleźć go w różnych miejscach*/

	DECLARE @id uniqueidentifier,
			@query nvarchar(1500)
	SET @id = CAST(@code AS uniqueidentifier)
	
	
	-- container id
	IF EXISTS (SELECT id FROM warehouse.Container WHERE id = @id) 
		SELECT ''container'' [type], id FROM warehouse.Container WHERE id = @id
	
	
	-- shift id
	IF EXISTS (SELECT id FROM warehouse.Shift WHERE id = @id) 
		SELECT ''shift'' [type], id FROM warehouse.Shift WHERE id = @id
	-- user id
	IF EXISTS (SELECT contractorId FROM contractor.ApplicationUser WHERE contractorId = @id)
		SELECT ''user'' [type] ,contractorId id, login  FROM contractor.ApplicationUser WHERE contractorId = @id
		
	-- drzewo grup kontenerów
	SELECT @query = ''IF EXISTS (SELECT xmlValue.value(''''(/warehouseMap/slotGroup/slotGroup[@id = '''''''''' + @code + '''''''''']/@id)[1]'''',''''varchar(100)'''') FROM configuration.Configuration WHERE [key] = ''''warehouse.warehouseMap'''')
		SELECT ''''tree'''' [type], xmlValue.value(''''(/warehouseMap/slotGroup/slotGroup[@id = '''''''''' + @code + '''''''''']/@id)[1]'''',''''varchar(100)'''') [id] FROM configuration.Configuration WHERE [key] = ''''warehouse.warehouseMap''''''
	EXEC(@query)
' 
END
GO
