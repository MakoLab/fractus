/*
name=[contractor].[p_getBank]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nJWPZSWfLSfO4YMxTty/hw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getBank]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getBank]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getBank]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getBank]
AS
	/*Pobranie danych o bankach*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    contractorId,
                                                bankNumber,
                                                swiftNumber,
                                                version
                                      FROM      contractor.Bank
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''bank''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnXML
' 
END
GO
