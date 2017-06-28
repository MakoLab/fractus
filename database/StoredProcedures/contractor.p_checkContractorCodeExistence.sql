/*
name=[contractor].[p_checkContractorCodeExistence]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
gJv6uJShICxi/1SMKiJ+Qg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_checkContractorCodeExistence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_checkContractorCodeExistence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_checkContractorCodeExistence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [contractor].[p_checkContractorCodeExistence]
@xmlVar XML
AS
BEGIN
	DECLARE @code varchar(100), @nip varchar(100), @id uniqueidentifier, @exists bit, @login varchar(100)
	
	SET @exists = 0  
	declare @msg nvarchar(max)
	select @msg = CAST(@xmlVar as nvarchar(max))
 

	SELECT
		@code = x.value(''code[1]'', ''varchar(100)''),
		@nip = x.value(''nip[1]'', ''varchar(100)''),			
		@id =  x.value(''id[1]'', ''char(36)''),
		@login =  NULLIF(x.value(''checkLogin[1]'', ''varchar(100)''),'''')
	FROM @xmlVar.nodes(''/root/contractor[1]'') AS a(x)

	
	IF (SELECT TOP 1 textValue FROM configuration.Configuration WHERE [key] = ''contractors.enforceCodeUniqueness'') = ''true''
	BEGIN
		IF EXISTS( SELECT id FROM contractor.Contractor WHERE code = NULLIF(RTRIM(@code),'''') AND id <> @id )
		SET @exists = 1
  
	END

	IF (SELECT TOP 1 textValue FROM configuration.Configuration WHERE [key] = ''contractors.enforceNipUniqueness'') = ''true''
	BEGIN
		SELECT @nip = dbo.f_extractPattern(@nip, ''%[0-9]%'')
		IF EXISTS(SELECT id FROM contractor.Contractor WHERE NULLIF(strippedNip, '''') = @nip AND id <> @id AND isOwnCompany = 0) SET @exists = 1
		select @id,@nip
	END

	IF @login IS NOT NULL
		BEGIN 
			SELECT @exists = 1 FROM contractor.ApplicationUser WHERE [login] = @login AND contractorId <> @id
		 
		END
	-- zwrocenie wyniku
	IF (@exists = 1) SELECT CAST(''<root>TRUE</root>'' AS  XML) XML
	ELSE SELECT CAST(''<root>FALSE</root>'' AS  XML) XML

END
' 
END
GO
