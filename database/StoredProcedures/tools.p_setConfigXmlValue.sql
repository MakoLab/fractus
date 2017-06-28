/*
name=[tools].[p_setConfigXmlValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nOXZny6jrXGues42AlUP/A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_setConfigXmlValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_setConfigXmlValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_setConfigXmlValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_setConfigXmlValue]
	@key varchar(100),
	@value xml
AS
	IF EXISTS (SELECT id FROM configuration.Configuration WHERE [key] = @key) UPDATE configuration.Configuration SET xmlValue = @value WHERE [key] = @key
	ELSE INSERT INTO configuration.Configuration (id, version, [key], xmlValue) VALUES (newid(), newid(), @key, @value)
' 
END
GO
