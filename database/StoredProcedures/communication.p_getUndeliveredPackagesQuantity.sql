/*
name=[communication].[p_getUndeliveredPackagesQuantity]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2ADb2Nd4UStHcCVZmwXt4A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getUndeliveredPackagesQuantity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getUndeliveredPackagesQuantity]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getUndeliveredPackagesQuantity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_getUndeliveredPackagesQuantity]
    @databaseId UNIQUEIDENTIFIER = NULL,
    @xmlVar XML = NULL
AS 
    BEGIN
		IF @xmlVar IS NOT NULL
			BEGIN
			SELECT @databaseId = @xmlVar.value(''.'',''char(36)'')

			SELECT  COUNT(id) AS ''data()''
				FROM    communication.OutgoingXmlQueue WITH ( NOLOCK )
				WHERE   sendDate IS NULL
						AND ( databaseId = @databaseId
							  OR @databaseId IS NULL
							)
			FOR XML PATH(''root''),TYPE
			END
		ELSE
			BEGIN	
				/*Pobranie danych o ilości rezultatów w postaci int*/
				SELECT  COUNT(id) AS result
				FROM    communication.OutgoingXmlQueue WITH ( NOLOCK )
				WHERE   sendDate IS NULL
						AND ( databaseId = @databaseId
							  OR @databaseId IS NULL
							)
             END       
                    
                    
    END
' 
END
GO
