/*
name=[communication].[p_getUnprocessedPackagesQuantity]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
S9xHhHi+kvbG4tr1r6AZVg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getUnprocessedPackagesQuantity]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getUnprocessedPackagesQuantity]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getUnprocessedPackagesQuantity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getUnprocessedPackagesQuantity]
AS 
    BEGIN
		/*Zwrócenie liczby rezultatów w postaci int*/    
        SELECT  COUNT(id) AS result
        FROM    communication.IncomingXmlQueue WITH ( NOLOCK )
        WHERE   executionDate IS NULL
    END
' 
END
GO
