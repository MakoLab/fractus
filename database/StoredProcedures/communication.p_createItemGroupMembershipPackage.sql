/*
name=[communication].[p_createItemGroupMembershipPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
eXKFOJq4DwgtCxTK/TiJmQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createItemGroupMembershipPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createItemGroupMembershipPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createItemGroupMembershipPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_createItemGroupMembershipPackage]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER

		IF EXISTS (SELECT x.value(''@action'',''varchar(10)'') FROM @xmlVar.nodes(''root/entry'') AS a ( x ) WHERE  x.value(''@action'',''varchar(10)'') IS NULL  )  
			RETURN 0;

		/*Pobranie danych o transakcji*/
        SELECT  @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
				@databaseId = x.value(''@databaseId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )
		/*Utworzenie zrzutu danych w postaci XML*/
        SELECT  @snap = ( SELECT    ( SELECT    x.value(''@previousVersion'',''char(36)'') AS ''@previousVersion'',
                                                x.value(''@action'',''varchar(10)'') AS ''@action'',
                                                x.value(''@id'', ''char(36)'') ''id'',
                                                ISNULL ( ItemGroupMembership.itemId, x.value(''@itemId'', ''char(36)'') ) ''itemId'',
                                                itemGroupId ''itemGroupId'',
                                                ISNULL(version,x.value(''@version'', ''char(36)'')) ''version'',
                                                x.value(''@_object1from'',''char(36)'') ''_object1from'',
                                                x.value(''@_object1to'',''char(36)'') ''_object1to'',
                                                x.value(''@_object2from'',''char(36)'') ''_object2from'',
                                                x.value(''@_object2to'',''char(36)'') ''_object2to''
                                      FROM      @xmlVar.nodes(''root/entry'') AS a ( x )
                                                LEFT JOIN item.ItemGroupMembership ON ItemGroupMembership.id = x.value(''@id'', ''char(36)'')
												where x.value(''@action'',''varchar(10)'') IS NOT NULL
                                    FOR XML PATH(''entry''), TYPE
                                    )
                        FOR XML PATH(''itemGroupMembership''), ROOT(''root'')
                        ) 
		/*Pobranie liczby wstawionych danych*/ 
        SET @rowcount = @@rowcount
        
        
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
                        ''ItemGroupMembership'',
                        @snap,
                        GETDATE()
                        
		/*Obsługa błędów i wyjątków*/
        IF @@error <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50011, 16, 1 ) ;
            END
    END
' 
END
GO
