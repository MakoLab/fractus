/*
name=[print].[p_getContainerContentPrint]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ReTYADIFw7hVAWDXKT4qAw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getContainerContentPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [print].[p_getContainerContentPrint]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[print].[p_getContainerContentPrint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [print].[p_getContainerContentPrint]
    @documentHeaderId UNIQUEIDENTIFIER
AS
    BEGIN
		DECLARE @xml XML
		SELECT @xml = ''<root><containerId>''+CAST(@documentHeaderId as varchar(36))+''</containerId></root>''
		EXEC warehouse.p_getContainerContent @xml
    END
' 
END
GO
