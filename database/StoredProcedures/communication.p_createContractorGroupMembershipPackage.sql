/*
name=[communication].[p_createContractorGroupMembershipPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WYunP2vaEWmDyL2TRfNspg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createContractorGroupMembershipPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createContractorGroupMembershipPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createContractorGroupMembershipPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createContractorGroupMembershipPackage]
@xmlVar XML
AS
BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER

		/*Pobranie danych o transakcji*/
        SELECT  @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )
		/*Utworzenie zrzutu danych w postaci XML*/
        SELECT  @snap = ( SELECT    ( SELECT    x.value(''@previousVersion'',''char(36)'') AS ''@previousVersion'',
                                                x.value(''@action'',''varchar(10)'') AS ''@action'',
                                                x.value(''@id'', ''char(36)'') ''id'',
                                                contractorId ''contractorId'',
                                                contractorGroupId ''contractorGroupId'',
                                                ISNULL(version,x.value(''@version'', ''char(36)'')) ''version'',
                                                x.value(''@_object1from'',''char(36)'') ''_object1from'',
                                                x.value(''@_object1to'',''char(36)'') ''_object1to'',
                                                x.value(''@_object2from'',''char(36)'') ''_object2from'',
                                                x.value(''@_object2to'',''char(36)'') ''_object2to''
                                      FROM      @xmlVar.nodes(''root/entry'') AS a ( x )
                                                LEFT JOIN contractor.ContractorGroupMembership ON ContractorGroupMembership.id = x.value(''@id'', ''char(36)'')
                                    FOR XML PATH(''entry''),  TYPE
                                    )
                        FOR XML PATH(''contractorGroupMembership''), ROOT(''root'')
                        ) 
		/*Pobranie liczby wstawionych danych*/ 
        SET @rowcount = @@rowcount
        
        
		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
                  deferredTransactionId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
                        @deferredTransactionId,
                        ''ContractorGroupMembership'',
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
