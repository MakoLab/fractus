/*
name=[document].[p_checkTechnologyNameExistence]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1EZBtKTbmRzQd+LmzvIV7g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkTechnologyNameExistence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkTechnologyNameExistence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkTechnologyNameExistence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkTechnologyNameExistence]
@xmlVar XML
AS
BEGIN
	DECLARE @value varchar(100), @id uniqueidentifier

	SELECT @value = @xmlVar.value(''(//name)[1]'', ''nvarchar(500)'')
	IF EXISTS(
		SELECT id 
		FROM document.DocumentAttrValue 
		WHERE documentFieldId IN ( 
			select id 
			from dictionary.DocumentField 
			where name =''Attribute_ProductionTechnologyName''
			)
		AND textValue = @value )
		BEGIN 
			SELECT CAST(''<root>TRUE</root>'' AS  XML) XML
		END	
	ELSE 
		BEGIN
			SELECT CAST(''<root>FALSE</root>'' AS  XML) XML
		END
END
' 
END
GO
