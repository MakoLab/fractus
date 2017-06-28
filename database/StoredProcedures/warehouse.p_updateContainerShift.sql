/*
name=[warehouse].[p_updateContainerShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ey/BvAeQ1HWP4scb3fL9aA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateContainerShift]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_updateContainerShift]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_updateContainerShift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_updateContainerShift] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
    BEGIN 

		/*Aktualizacja danych o przesunięciach wewnątrz magazynowych*/
        UPDATE  warehouse.ContainerShift
        SET     containerId = CASE WHEN con.exist(''containerId'') = 1
                                                  THEN con.query(''containerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				parentContainerId = CASE WHEN con.exist(''parentContainerId'') = 1
                                                  THEN con.query(''parentContainerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				slotContainerId = CASE WHEN con.exist(''slotContainerId'') = 1
                                                  THEN con.query(''slotContainerId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
				shiftTransactionId = CASE WHEN con.exist(''shiftTransactionId'') = 1
                                                  THEN con.query(''shiftTransactionId'').value(''.'', ''char(36)'')
                                                  ELSE NULL
                                             END,
                ordinalNumber = CASE WHEN con.exist(''ordinalNumber'') = 1
                                 THEN con.query(''ordinalNumber'').value(''.'', ''int'')
                                 ELSE NULL
                            END,
                version = CASE WHEN con.exist(''_version'') = 1
                               THEN con.query(''_version'').value(''.'', ''char(36)'')
                               ELSE NULL
                          END
        FROM    @xmlVar.nodes(''/root/containerShift/entry'') AS C ( con )
        WHERE   ContainerShift.id = con.query(''id'').value(''.'', ''char(36)'')

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: ContainerShift; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
    END
' 
END
GO
