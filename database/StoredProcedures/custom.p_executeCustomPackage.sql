/*
name=[custom].[p_executeCustomPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4sESn+G/1ZyDVfAlg6AgmA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_executeCustomPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_executeCustomPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_executeCustomPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_executeCustomPackage] @xmlVar XML
AS
BEGIN 
	/* TYP PACZKI
		<root typ="packageRequest" bussinesObjectId="" bussinesObjectType=""/> - prośba o wysłanie paczki komunikacyjnej z obiektem
		<root typ="ComparisionData"> <object .../></root> - paczka z danymi do próby spójności danych 
		<root typ="ComparisionDataResponse"> <object .../></root> - paczka powracajaca z danymi do próby spójności danych
		<root typ="sql"></root> - paczka z tekstem sql do wykonania 
	*/
	DECLARE @typ varchar(50),
			@bussinesObjectType varchar(50),
			@bussinesObjectId UNIQUEIDENTIFIER,
			@branch uniqueidentifier,
			@databaseId uniqueidentifier,
			@version uniqueidentifier,
			@x XML,@i int ,@c int,
			@symbol varchar(50),
			@localModificationDate datetime, 
			@remoteModificationDate datetime, 
			@localVersion uniqueidentifier, 
			@remoteVersion uniqueidentifier,
			@id uniqueidentifier,  
			@previousVersion uniqueidentifier,
			@sql varchar(max)

	DECLARE @tmp TABLE (i int identity(1,1), typ varchar(50), symbol varchar(50), id uniqueidentifier,localModificationDate datetime, remoteModificationDate datetime, localVersion uniqueidentifier, remoteVersion uniqueidentifier )

	SELECT @branch = id , @databaseId = databaseId 
	FROM dictionary.Branch 
	WHERE databaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] like ''communication.databaseId'')

	SELECT @typ = @xmlVar.value(''(root/root/@typ)[1]'',''varchar(50)'')
	PRINT @typ
	IF @typ = ''sql''
		BEGIN
			SELECT @sql = @xmlVar.value(''(root/root[@typ="sql"])[1]'',''varchar(50)'')
			EXEC (@sql)
		END

	IF @typ = ''userMessage''
		BEGIN
			
			SELECT @x = @xmlVar.query(''(root/root)'')
			SET @x.modify(''insert attribute source {"Communication"} into (root)[1] '')
			--SELECT @x.value(''(root/messages/entry/receiveDate)[1]'',''varchar(50)'')

			IF  (SELECT @x.value(''(root/messages/entry/receiveDate)[1]'',''varchar(50)'')) IS NOT NULL
				BEGIN
					PRINT ''p_updateUserMessage''
					EXEC tools.p_updateUserMessage @x
				END
			ELSE
				BEGIN
					PRINT ''p_sendUserMessage''
					EXEC  tools.p_sendUserMessage @x
				END
		END

	IF @typ = ''packageRequest'' AND (SELECT textValue FROM configuration.Configuration WHERE [key] like ''system.isHeadquarter'') = ''false''
		BEGIN
			SELECT @bussinesObjectType = @xmlVar.value(''(root/root/@bussinesObjectType)[1]'',''varchar(50)'')
			SELECT @bussinesObjectId = @xmlVar.value(''(root/root/@bussinesObjectId)[1]'',''varchar(50)'')

			IF @bussinesObjectType = ''WarehouseDocumentHeader''
				BEGIN
					SELECT @version = [version] FROM document.WarehouseDocumentHeader  WHERE id = @bussinesObjectId
					SELECT @xmlVar = ''<root previousVersion="'' + CAST(@bussinesObjectId AS varchar(50)) + ''" businessObjectId="''+ CAST(@bussinesObjectId AS varchar(50)) + ''"  localTransactionId="''+ CAST(@bussinesObjectId AS varchar(50)) + ''" deferredTransactionId="''+ CAST(@bussinesObjectId AS varchar(50)) + ''" databaseId="''+ CAST(@databaseId AS varchar(50)) + ''"/>''
					UPDATE document.WarehouseDocumentHeader set [version] = newid() WHERE id = @bussinesObjectId
					EXEC [communication].[p_createWarehouseDocumentPackage] @xmlVar
				END
			IF @bussinesObjectType = ''CommercialDocumentHeader''
				BEGIN
					SELECT @version = [version] FROM document.CommercialDocumentHeader  WHERE id = @bussinesObjectId
					SELECT @xmlVar = ''<root previousVersion="'' + CAST(@bussinesObjectId AS varchar(50)) + ''" businessObjectId="''+ CAST(@bussinesObjectId AS varchar(50)) + ''"  localTransactionId="''+ CAST(@bussinesObjectId AS varchar(50)) + ''" deferredTransactionId="''+ CAST(@bussinesObjectId AS varchar(50)) + ''" databaseId="''+ CAST(@databaseId AS varchar(50)) + ''"/>''
					UPDATE document.CommercialDocumentHeader set [version] = newid() WHERE id = @bussinesObjectId
					EXEC [communication].[p_createCommercialDocumentPackage] @xmlVar
				END
		END

		IF @typ = ''ComparisionData'' AND (SELECT textValue FROM configuration.Configuration WHERE [key] like ''system.isHeadquarter'') = ''false''
			BEGIN
				EXEC  tools.p_createBussinesObjectVersion @xmlVar = @x OUT, @branchId = @branch
				--SELECT @x = (SELECT @x ) 
				INSERT INTO communication.OutgoingXmlQueue(id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], sendDate, creationDate )
				SELECT NEWID(), NEWID(), NEWID(), @databaseId, ''Custom'',@x,NULL, GETDATE()
			END

		IF @typ = ''ComparisionDataResponse'' AND (SELECT textValue FROM configuration.Configuration WHERE [key] like ''system.isHeadquarter'') = ''true''
			BEGIN
				/*Porównywanie wersji obiektów i dalsza logika związana z próbą synchronizacji */
				SELECT @x = @xmlVar
				/*Ustawienie oddziału*/
				SELECT @branch = @xmlVar.value(''(root/root/@branchId)[1]'',''char(36)'')
				SELECT @databaseId = databaseId 
				FROM dictionary.Branch
				WHERE id = @branch

				INSERT INTO @tmp 
				EXEC tools.p_compareBussinesObjectVersion @x
				SELECT @i = 1 , @c = @@ROWCOUNT
				
				WHILE @i <= @c
					BEGIN
						SELECT	@id = id,   
								@previousVersion = remoteVersion,
								@symbol = symbol,
								@localModificationDate = localModificationDate, 
								@remoteModificationDate = remoteModificationDate, 
								@localVersion = localVersion, 
								@remoteVersion = remoteVersion,
								@typ = typ
						FROM @tmp 
						WHERE i = @i

						/* Case do określenia rodzaju sprawy */
						IF (@localModificationDate IS NOT NULL AND @remoteModificationDate IS NULL)
						/*Tutaj następuje wysłanie paczki z oddziału centralnego*/
							BEGIN
								SELECT @xmlVar = ''<root businessObjectId="''+ CAST(@id AS varchar(50)) + ''" '' + ISNULL(''previousVersion="''+ CAST(@previousVersion AS varchar(50)) + ''"'' ,'''') + '' localTransactionId="''+ CAST(@id AS varchar(50)) + ''" deferredTransactionId="''+ CAST(@id AS varchar(50)) + ''" databaseId="''+ CAST(@databaseId AS varchar(50)) + ''"/>''
			
								IF(SELECT typ FROM @tmp WHERE i = @i) = ''WarehouseDocumentHeader''
									BEGIN
										UPDATE document.WarehouseDocumentHeader set [version] = newid() WHERE id = @id
										EXEC [communication].[p_createWarehouseDocumentPackage] @xmlVar
									END
								ELSE
									BEGIN
										UPDATE document.CommercialDocumentHeader set [version] = newid() WHERE id = @id
										EXEC [communication].[p_createCommercialDocumentPackage] @xmlVar
									END
							END
						ELSE IF ( @localModificationDate IS NULL AND @remoteModificationDate IS NOT NULL ) 
						/* Wysyłanie paczki z prośbą o odesłanie obiekty - typ "packageRequest" */
							BEGIN
								
								INSERT INTO communication.OutgoingXmlQueue(id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], sendDate, creationDate )
								SELECT NEWID(), NEWID(), NEWID(), @databaseId, ''Custom'',''<root> <root typ="packageRequest" bussinesObjectId="'' + CAST(@id AS varchar(50)) + ''" bussinesObjectType="''+ @typ +''"/> </root>'',NULL, GETDATE()
							END

						SELECT @i = @i + 1
					END

			END

END
' 
END
GO
