/*
name=[warehouse].[p_insertContainerShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dBfLFz/SLcGOkVEV0g8MCw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertContainerShift]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_insertContainerShift]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_insertContainerShift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_insertContainerShift] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	/*Wstawienie danych o pozycjach przesunięcia kontenera*/
    INSERT  INTO [warehouse].ContainerShift
            (
              id,
              containerId,
              parentContainerId,
			  slotContainerId,
			  shiftTransactionId,
              ordinalNumber,
			  version
            )
            SELECT 
              id,
              containerId,
              parentContainerId,
			  slotContainerId,
			  shiftTransactionId,
              ordinalNumber,
			  version

			FROM OPENXML(@idoc, ''/root/containerShift/entry'')
				WITH(
					id char(36) ''id'',
                    containerId char(36) ''containerId'',
                    parentContainerId char(36) ''parentContainerId'',
					slotContainerId char(36) ''slotContainerId'',
					shiftTransactionId char(36) ''shiftTransactionId'',
					ordinalNumber int ''ordinalNumber'',
					version char(36) ''version''

             )
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ContainerShift; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
' 
END
GO
