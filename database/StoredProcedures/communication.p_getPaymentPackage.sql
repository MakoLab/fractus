/*
name=[communication].[p_getPaymentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YZASH9RjP988kVb4vDmEIA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getPaymentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getPaymentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getPaymentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getPaymentPackage] 
@xmlVar XML
AS /*Gets item xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML,
				@idoc int

		DECLARE @tmp TABLE (id uniqueidentifier)

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar		
		INSERT INTO @tmp (id)
		SELECT id
		FROM OPENXML(@idoc, ''/root/id'')
				WITH(
					 id char(36) ''.'' 
					)
		EXEC sp_xml_removedocument @idoc
        
		/*Tworzenie obrazu danych*/
        SELECT  @result = (         
							( 
						SELECT
                            ( SELECT    ( 
										  SELECT *
                                          FROM   finance.Payment
                                          WHERE  id IN ( SELECT id FROM @tmp )
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''payment''), TYPE
                            ),
                            ( SELECT    ( SELECT    s.*
                                          FROM      finance.PaymentSettlement s
										  	JOIN finance.Payment p ON s.incomePaymentId = p.id OR s.outcomePaymentId = p.id
										  WHERE   p.id  IN ( SELECT id FROM @tmp ) 
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR XML PATH(''paymentSettlement''), TYPE
                            )
						FOR XML PATH(''root''), TYPE
                ) )

        /*Zwrócenie wyników*/                  
        SELECT  @result 
        /*Obsługa pustego resulta*/
        IF @@rowcount = 0 
            SELECT  ''''
            FOR XML PATH(''root''), TYPE
    END
' 
END
GO
