/*
name=[finance].[p_getFinancialReportStatusById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
55BZ2JNcczRdOz4H94O9aA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportStatusById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getFinancialReportStatusById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getFinancialReportStatusById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  PROCEDURE [finance].[p_getFinancialReportStatusById]
@financialReportId UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE 
		@x XML


	SELECT @x = (
		SELECT 	CASE 
							WHEN ISNULL( eau.c ,0) = ISNULL(u.c,0) AND ISNULL(u.c,0) <> 0 THEN ''exportedAndUnchanged'' 
							WHEN  ISNULL( eac.c ,0) = ISNULL(u.c,0)  AND ISNULL(u.c,0) <> 0 THEN ''exportedAndChanged''
							WHEN ISNULL(u.c,0) = 0 AND ex.id IS NOT NULL THEN ''exportedAndUnchanged''
							ELSE ''unexported'' END  AS ''@objectExported'',
				r.id  AS ''data()''
		FROM finance.FinancialReport r WITH(NOLOCK) 
			JOIN dictionary.FinancialRegister fr ON r.financialRegisterId = fr.id 
			LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
							FROM accounting.ExternalMapping  ex WITH(NOLOCK) 
								join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version = ISNULL(ex.objectVersion ,newid())
							WHERE fh.status >= 40
							GROUP BY fh.financialReportId 
						) eau ON eau.financialReportId = r.id
			LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
							FROM accounting.ExternalMapping   ex WITH(NOLOCK)
								join document.FinancialDocumentHeader fh on fh.id = ex.id AND fh.version <> ISNULL(ex.objectVersion ,newid()) 
							WHERE fh.status >= 40
							GROUP BY fh.financialReportId 
						) eac ON eac.financialReportId = r.id 
			LEFT JOIN (	SELECT fh.financialReportId  , count(fh.id) c
						FROM  document.FinancialDocumentHeader fh
						WHERE fh.status >= 40
						GROUP BY fh.financialReportId 
						) u ON u.financialReportId = r.id 
			LEFT JOIN accounting.ExternalMapping  ex WITH(NOLOCK) ON r.id = ex.id	AND r.version = ex.objectVersion																
		WHERE r.id = @financialReportId
		FOR XML PATH(''id''), TYPE
		) 

	SELECT @x FOR XML PATH(''root''), TYPE
		
END
' 
END
GO
