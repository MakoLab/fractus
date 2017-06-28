/*
name=[contractor].[p_insertContractorGroupMembershipCustom]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
sQlSk4ATvWHf/4VTpH/29w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorGroupMembershipCustom]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractorGroupMembershipCustom]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorGroupMembershipCustom]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertContractorGroupMembershipCustom]
@xmlVar XML
AS

DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
        @snap xml,
        @localTransactionId UNIQUEIDENTIFIER,
        @deferredTransactionId UNIQUEIDENTIFIER,
		@databaseId UNIQUEIDENTIFIER
		
DECLARE @tmp TABLE (id uniqueidentifier)
	/*Jesli towar jednocześnie może należeć do jednej grupy, usuwam go z innych*/
	IF ISNULL((select textValue from configuration.Configuration where [key] like ''contractors.allowOneGroupMembership''),''false'') = ''true''
		BEGIN
			
			/*Pobranie danych o transakcji*/
			SELECT  @localTransactionId = ISNULL(NULLIF(x.value(''@localTransactionId'',''char(36)''),''''),newid()),
					@deferredTransactionId = ISNULL(NULLIF(x.value(''@deferredTransactionId'',''char(36)''),''''),newid()),
					@databaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId'')
			FROM    @xmlVar.nodes(''root'') AS a ( x )
			
			/*Pobranie listy przypisań istniejacych które są ponownie przypisywane w tej samej postaci*/
			INSERT INTO @tmp
			SELECT cg.id
			FROM      @xmlVar.nodes(''root/contractorGroupMembership/entry'') AS a ( x )
				LEFT JOIN contractor.contractorGroupMembership cg ON cg.contractorId = x.value(''(contractorId)[1]'', ''char(36)'')  AND cg.contractorGroupId = x.value(''(contractorGroupId)[1]'', ''char(36)'') 
			WHERE cg.id IS NOT NULL	
			
			/*Utworzenie zrzutu danych w postaci XML*/
			SELECT  @snap = ( SELECT    ( SELECT    
													''delete'' ''@action'',
													cg.id ''id'',
													cg.contractorId ''contractorId'',
													cg.contractorGroupId ''contractorGroupId'',
													cg.version ''version''
										  FROM      @xmlVar.nodes(''root/contractorGroupMembership/entry'') AS a ( x )
													LEFT JOIN contractor.contractorGroupMembership  cg ON cg.contractorId = x.value(''(contractorId)[1]'', ''char(36)'') 
													LEFT JOIN @tmp t ON cg.id = t.id
										  WHERE t.id IS NULL		
										FOR XML PATH(''entry''), TYPE
										)
							FOR XML PATH(''contractorGroupMembership''), ROOT(''root'')
							) 
	 
	 IF @snap.exist(''/root/contractorGroupMembership/entry/id'') = 1
		BEGIN
			INSERT  INTO communication.OutgoingXmlQueue ( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], creationDate )
			SELECT  NEWID(),@localTransactionId, @deferredTransactionId,@databaseId,''ContractorGroupMembership'',@snap,GETDATE()
		END
		
			DELETE FROM [contractor].[contractorGroupMembership]  
			WHERE contractorId IN (	SELECT NULLIF(con.value(''(contractorId)[1]'', ''char(36)''), '''')
										FROM    @xmlVar.nodes(''/root/contractorGroupMembership/entry'') AS C ( con )
										)
				 AND id NOT IN (SELECT id FROM @tmp)
			
				 
		DELETE FROM @tmp	
	 

		END
 
 
 	/*Informacje o istniejących przypisaniach do grup*/
	INSERT INTO @tmp (id)
	SELECT im.id
	    FROM    @xmlVar.nodes(''/root/contractorGroupMembership/entry'') AS C ( con )
		LEFT JOIN [contractor].[contractorGroupMembership] im ON im.contractorId = con.value(''(contractorId)[1]'', ''char(36)'') AND im.contractorGroupId = con.value(''(contractorGroupId)[1]'', ''char(36)'')
	WHERE im.id IS NOT NULL
	
	
		/*Wstawienie danych i wartościach atrybutów towarów*/
		INSERT INTO [contractor].[contractorGroupMembership]
			   ([id]
			   ,[contractorId]
			   ,[contractorGroupId]
			   ,[version])
		SELECT  newid(),
				NULLIF(con.value(''(contractorId)[1]'', ''char(36)''), ''''),
				NULLIF(con.value(''(contractorGroupId)[1]'', ''char(36)''), ''''),
				newid()
		FROM    @xmlVar.nodes(''/root/contractorGroupMembership/entry'') AS C ( con )
				LEFT JOIN [contractor].[contractorGroupMembership] cg ON cg.contractorId = con.value(''(contractorId)[1]'', ''char(36)'') AND cg.contractorGroupId = con.value(''(contractorGroupId)[1]'', ''char(36)'')
		WHERE cg.id IS NULL

		/*Pobranie danych o transakcji*/
        SELECT  @localTransactionId = ISNULL(NULLIF(x.value(''@localTransactionId'',''char(36)''),''''),newid()),
                @deferredTransactionId = ISNULL(NULLIF(x.value(''@deferredTransactionId'',''char(36)''),''''),newid()),
				@databaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )
        
		/*Utworzenie zrzutu danych w postaci XML*/
        SELECT  @snap = ( SELECT    ( SELECT    
                                                ''insert'' ''@action'',
                                                cg.id ''id'',
                                                x.value(''(contractorId)[1]'', ''char(36)'') ''contractorId'',
                                                x.value(''(contractorGroupId)[1]'', ''char(36)'') ''contractorGroupId'',
                                                cg.version ''version''
                                      FROM      @xmlVar.nodes(''root/contractorGroupMembership/entry'') AS a ( x )
                                                LEFT JOIN contractor.contractorGroupMembership  cg ON cg.contractorId = x.value(''(contractorId)[1]'', ''char(36)'') AND cg.contractorGroupId = x.value(''(contractorGroupId)[1]'', ''char(36)'')
                                       			LEFT JOIN @tmp t ON cg.id = t.id
                                      WHERE t.id IS NULL     
                                    FOR XML PATH(''entry''), TYPE
                                    )
                        FOR XML PATH(''contractorGroupMembership''), ROOT(''root'')
                        ) 

	 IF @snap.exist(''/root/contractorGroupMembership/entry/id'') = 1
		BEGIN
			INSERT  INTO communication.OutgoingXmlQueue ( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], creationDate )
			SELECT  NEWID(),@localTransactionId, @deferredTransactionId,@databaseId,''ContractorGroupMembership'',@snap,GETDATE()
		END
	

SELECT CAST(''<root/>'' as xml)
' 
END
GO
