/*
name=[document].[xp_valuateInvoice_old]
version=1.0.1
lastUpdate=2017-01-24 10:37:21

*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_valuateInvoice_old]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[xp_valuateInvoice_old]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[xp_valuateInvoice_old]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[xp_valuateInvoice_old]
	@commercialDocumentHeaderId [uniqueidentifier],
	@localTransactionId [uniqueidentifier],
	@deferredTransactionId [uniqueidentifier],
	@databaseId [uniqueidentifier]
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [Procedury_CLR2].[StoredProcedures].[xp_valuateInvoice]' 
END
GO
