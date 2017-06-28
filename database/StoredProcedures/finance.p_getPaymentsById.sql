/*
name=[finance].[p_getPaymentsById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
crvl6xh2c5De3MxRR/tDmw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getPaymentsById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getPaymentsById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getPaymentsById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [finance].[p_getPaymentsById]
@xmlVar XML
AS
BEGIN

DECLARE @idoc int


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar


	DECLARE @tmp TABLE ( id UNIQUEIDENTIFIER )




	INSERT INTO @tmp ( id )
	SELECT id
	FROM OPENXML(@idoc, ''/root/id'')
		WITH (
				id char(36) ''.''
			)

	EXEC sp_xml_removedocument @idoc



SELECT	( SELECT    ( SELECT    p.*
                      FROM      @tmp t 
						JOIN [finance].Payment p ON t.id = p.id
                      FOR XML PATH(''entry''), TYPE
                     )
          FOR XML PATH(''payment''), TYPE
         ),
         ( SELECT    ( SELECT * FROM (
						SELECT    p.*
                       FROM      [finance].PaymentSettlement p
						JOIN @tmp t ON  p.incomePaymentId = t.id
					   UNION 
					   SELECT    p.*
                       FROM      [finance].PaymentSettlement p
						JOIN @tmp t ON p.outcomePaymentId = t.id
						) x
                            FOR  XML PATH(''entry''), TYPE
                       )
           FOR XML PATH(''paymentSettlement''), TYPE
          )
    FOR XML PATH(''root''),TYPE
   -- ) AS returnsXML
END
' 
END
GO
