/*
name=[custom].[p_getPortaCompleteItemDetails]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xuBkHAqxWh4t8dZWqtm2Zw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getPortaCompleteItemDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getPortaCompleteItemDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getPortaCompleteItemDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_getPortaCompleteItemDetails]
	@xmlVar XML
AS
BEGIN
	DECLARE @idoc int
	DECLARE @tmp_ TABLE (code varchar(100))

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

		INSERT INTO @tmp_ (code)
		SELECT [code]
		FROM OPENXML(@idoc, ''/root/line'')
					WITH(code nvarchar(500) ''code'')
	EXEC sp_xml_removedocument @idoc

	SELECT (
		SELECT 
			[pcid].[ean]
			, [pcid].[itemGroupFamilyCode]
			, [pcid].[code]
			, [pcid].[name]
			, [pcid].[price]
			, [pcid].[field1]
		FROM @tmp_ t 
			JOIN [custom].[portaCompleteItemDetails] [pcid]
				ON [t].[code]= [pcid].[code]
		FOR XML PATH(''line''),TYPE
	) FOR XML PATH(''root''), TYPE

END
' 
END
GO
