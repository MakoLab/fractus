/*
name=[tools].[p_setConfigTextValue]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Kz8cVo4Be83IsqxoRwwxYQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_setConfigTextValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_setConfigTextValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_setConfigTextValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_setConfigTextValue]
	@key varchar(100),
	@value varchar(1000)
AS
	IF EXISTS (SELECT id FROM configuration.Configuration WHERE [key] = @key) UPDATE configuration.Configuration SET textValue = @value WHERE [key] = @key
	ELSE INSERT INTO configuration.Configuration (id, version, [key], textValue) VALUES (newid(), newid(), @key, @value)
' 
END
GO
