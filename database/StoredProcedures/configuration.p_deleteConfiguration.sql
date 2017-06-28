/*
name=[configuration].[p_deleteConfiguration]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
aJF4khCyetSv4B/Nng/jmQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_deleteConfiguration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_deleteConfiguration]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_deleteConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [configuration].[p_deleteConfiguration] 
@xmlVar XML
AS
BEGIN
	DECLARE 
		@key varchar(100),
		@level varchar(50),
        @localTransactionId UNIQUEIDENTIFIER,
        @deferredTransactionId UNIQUEIDENTIFIER,
		@databaseId UNIQUEIDENTIFIER,
		@snap XML

	DECLARE @con TABLE (id uniqueidentifier, version uniqueidentifier)

	SELECT 
		@key = x.query(''key'').value(''.'',''varchar(100)''),
		@level = x.query(''level'').value(''.'',''varchar(50)''),
        @localTransactionId = x.query(''localTransactionId'').value(''.'',''char(36)''),
        @deferredTransactionId = x.query(''deferredTransactionId'').value(''.'',''char(36)''),
		@databaseId = x.query(''databaseId'').value(''.'',''char(36)'') 
	FROM @xmlVar.nodes(''root'') AS a(x)

	IF @level = ''SYSTEM'' 
			BEGIN
				INSERT INTO @con (id, version)
				SELECT id ,version
				FROM configuration.Configuration
				WHERE [key] = @key AND (companyContractorId IS NULL AND branchId IS NULL AND userProfileId IS NULL AND workstationId IS NULL AND applicationUserId IS NULL)
			END
	IF @level = ''COMPANY''
			BEGIN
				INSERT INTO @con (id, version)
				SELECT id ,version
				FROM configuration.Configuration
				WHERE [key] = @key AND (companyContractorId IS NULL)
			END
				
	IF @level = ''BRANCH''
			BEGIN
				INSERT INTO @con (id, version)
				SELECT id ,version
				FROM configuration.Configuration
				WHERE [key] = @key AND (branchId IS NULL)
			END
	IF @level = ''USERPROFILE''
			BEGIN
				INSERT INTO @con (id, version)
				SELECT id ,version
				FROM configuration.Configuration
				WHERE [key] = @key AND (userProfileId IS NULL)
			END
	IF @level = ''WORKSTATION''
			BEGIN
				INSERT INTO @con (id, version)
				SELECT id ,version
				FROM configuration.Configuration
				WHERE [key] = @key AND (workstationId IS NULL)
			END
	IF @level = ''USER''
			BEGIN
				INSERT INTO @con (id, version)
				SELECT id ,version
				FROM configuration.Configuration
				WHERE [key] = @key AND (applicationUserId IS NULL)
			END

	DELETE FROM configuration.Configuration 
	WHERE id IN ( SELECT id FROM @con )


	SELECT @snap = (SELECT (
		SELECT (
			SELECT ''delete'' AS ''@action'' , id 
			FROM @con 
			FOR XML PATH(''entry''), TYPE
		) FOR XML PATH(''configuration''),TYPE
	) FOR XML PATH(''root'') , TYPE)

	/*Wstawienie danych*/
    INSERT  INTO communication.OutgoingXmlQueue
            (
              id,
              localTransactionId,
              deferredTransactionId,
			  databaseId,
              [type],
              [xml],
              creationDate
            )
    SELECT  NEWID(),
            @localTransactionId,
            @deferredTransactionId,
			@databaseId,
            ''Configuration'',
            @snap,
            GETDATE()     

END
' 
END
GO
