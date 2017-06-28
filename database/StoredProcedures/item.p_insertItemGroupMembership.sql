/*
name=[item].[p_insertItemGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FvXVlxHU3zd2tIJDKB2eqA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_insertItemGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_insertItemGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 
CREATE PROCEDURE [item].[p_insertItemGroupMembership]
@xmlVar XML
AS
--select @xmlVar = ''<root applicationUserId="D1F80960-EC30-48E4-979B-F7A5D33C25B3"><itemGroupMembership><entry><itemGroupId>05C86E39-D0FA-476C-B702-51AB8298E95F</itemGroupId><itemId>5B386D69-59D3-48EA-92D2-76B2EA15B496</itemId></entry></itemGroupMembership></root>''

DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
        @snap xml,
        @localTransactionId UNIQUEIDENTIFIER,
        @deferredTransactionId UNIQUEIDENTIFIER,
		@databaseId UNIQUEIDENTIFIER
		
DECLARE @tmp TABLE (id uniqueidentifier)
--return 0;   

	/*Jesli towar jednocześnie może należeć do jednej grupy, usuwam go z innych*/
	IF ISNULL((select textValue from configuration.Configuration where [key] like ''items.allowOneGroupMembership''),''false'') = ''true''
		BEGIN
			
			/*Pobranie danych o transakcji*/
			SELECT  @localTransactionId = ISNULL(NULLIF(x.value(''@localTransactionId'',''char(36)''),''''),newid()),
					@deferredTransactionId = ISNULL(NULLIF(x.value(''@deferredTransactionId'',''char(36)''),''''),newid()),
					@databaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId'')
			FROM    @xmlVar.nodes(''root'') AS a ( x )
			
			/*Pobranie listy przypisań istniejacych które są ponownie przypisywane w tej samej postaci*/
			INSERT INTO @tmp
			SELECT cg.id
			FROM      @xmlVar.nodes(''root/itemGroupMembership/entry'') AS a ( x )
				LEFT JOIN item.ItemGroupMembership cg ON cg.itemId = x.value(''(itemId)[1]'', ''char(36)'')  AND cg.itemGroupId = x.value(''(itemGroupId)[1]'', ''char(36)'') 
			WHERE cg.id IS NOT NULL	
			
			/*Utworzenie zrzutu danych w postaci XML*/
			SELECT  @snap = ( SELECT    ( SELECT    
													''delete'' ''@action'',
													cg.id ''id'',
													cg.itemId ''itemId'',
													cg.itemGroupId ''itemGroupId'',
													cg.version ''version''
										  FROM      @xmlVar.nodes(''root/itemGroupMembership/entry'') AS a ( x )
													LEFT JOIN item.ItemGroupMembership cg ON cg.itemId = x.value(''(itemId)[1]'', ''char(36)'') 
													LEFT JOIN @tmp t ON cg.id = t.id
										  WHERE t.id IS NULL	AND 	cg.itemId IS NOT NULL
										FOR XML PATH(''entry''), TYPE
										)
							FOR XML PATH(''itemGroupMembership''), ROOT(''root'')
							) 
			/*Sprawdzenie istnienia elementów do wysłania w paczce*/				
	 		IF @snap.exist(''/root/itemGroupMembership/entry/id'') = 1
				BEGIN
					INSERT  INTO communication.OutgoingXmlQueue ( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml], creationDate )
					SELECT  NEWID(),@localTransactionId, @deferredTransactionId,@databaseId,''ItemGroupMembership'',@snap,GETDATE()
				END
				
			DELETE FROM [item].[itemGroupMembership]  
			WHERE itemId IN (	SELECT NULLIF(con.value(''(itemId)[1]'', ''char(36)''), '''')
										FROM    @xmlVar.nodes(''/root/itemGroupMembership/entry'') AS C ( con )
										)
				AND id NOT IN (SELECT id FROM @tmp)
			
			DELETE FROM @tmp	

		END 

	
	/*Informacje o istniejących przypisaniach do grup*/
	INSERT INTO @tmp (id)
	SELECT im.id
	    FROM    @xmlVar.nodes(''/root/itemGroupMembership/entry'') AS C ( con )
		LEFT JOIN [item].[ItemGroupMembership] im ON im.itemId = con.value(''(itemId)[1]'', ''char(36)'') AND im.itemGroupId = con.value(''(itemGroupId)[1]'', ''char(36)'')
	WHERE im.id IS NOT NULL
	
	
    /*Wstawienie danych i wartościach atrybutów towarów*/
    INSERT INTO [item].[ItemGroupMembership]
           ([id]
           ,[itemId]
           ,[itemGroupId]
           ,[version])
    SELECT  newid(),
            NULLIF(con.value(''(itemId)[1]'', ''char(36)''), ''''),
            NULLIF(con.value(''(itemGroupId)[1]'', ''char(36)''), ''''),
            newid()
    FROM    @xmlVar.nodes(''/root/itemGroupMembership/entry'') AS C ( con )
		LEFT JOIN [item].[ItemGroupMembership] im ON im.itemId = con.value(''(itemId)[1]'', ''char(36)'') AND im.itemGroupId = con.value(''(itemGroupId)[1]'', ''char(36)'')
	WHERE im.id IS NULL AND NULLIF(con.value(''(itemId)[1]'', ''char(36)''), '''') IS NOT NULL
	
	
		/*Pobranie danych o transakcji*/
        SELECT  @localTransactionId = NULLIF(x.value(''@localTransactionId'',''char(36)''),''''),
                @deferredTransactionId = NULLIF(x.value(''@deferredTransactionId'',''char(36)''),''''),
				@databaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )
		/*Utworzenie zrzutu danych w postaci XML*/
        SELECT  @snap = ( SELECT    ( SELECT    
                                                ''insert'' ''@action'',
                                                im.id ''id'',
                                                x.value(''(itemId)[1]'', ''char(36)'') ''itemId'',
                                                 x.value(''(itemGroupId)[1]'', ''char(36)'') ''itemGroupId'',
                                                im.version ''version''
                                                
                                      FROM      @xmlVar.nodes(''root/itemGroupMembership/entry'') AS a ( x )
										LEFT JOIN item.ItemGroupMembership im ON im.itemId = x.value(''(itemId)[1]'', ''char(36)'') AND im.itemGroupId = x.value(''(itemGroupId)[1]'', ''char(36)'')
										LEFT JOIN @tmp t ON im.id = t.id
                                      WHERE t.id IS NULL AND x.value(''(itemId)[1]'', ''char(36)'') IS NOT NULL
                                      /*Na podstawie listy @tmp nie wyślę ponownie przypisań istniejących przed operacją, były zgłoszenia do Umbra że takim przypadku mu coś staje... */
                                    FOR XML PATH(''entry''), TYPE
                                    )
                        FOR XML PATH(''itemGroupMembership''), ROOT(''root'')
                        ) 
                        
		 IF @snap.exist(''/root/itemGroupMembership/entry/id'') = 1
			BEGIN
				  INSERT  INTO communication.OutgoingXmlQueue
						( id,
						  localTransactionId,
						  deferredTransactionId,
						  databaseId,
						  [type],
						  [xml],
						  creationDate
						)
				SELECT  NEWID(),
						ISNULL(@localTransactionId,newid()),
						ISNULL(@deferredTransactionId,newid()),
						@databaseId,
						''ItemGroupMembership'',
						@snap,
						GETDATE()
		   END                     
                        
SELECT   CAST(''<root/>'' as xml)' 
END
GO
