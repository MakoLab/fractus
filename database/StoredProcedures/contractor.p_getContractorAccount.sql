/*
name=[contractor].[p_getContractorAccount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SV/BdPfcPNYwFhW6q7gvjw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorAccount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorAccount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorAccount]
AS 
	/*Pobranie danych o kontach kotrahenta*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                contractorId,
                                                bankContractorId,
                                                accountNumber,
                                                version
                                      FROM      contractor.ContractorAccount
                                      ORDER BY  [order]
                                    FOR XML PATH(''entry''), TYPE
                                    )
                        FOR XML PATH(''contractorAccount''), TYPE
                        )
            FOR XML PATH(''root''), TYPE
            ) AS returnXML
' 
END
GO
