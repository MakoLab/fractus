/*
name=[accounting].[f_getContractorPayment]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4rg+u84PoJszlMzUroesug==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[f_getContractorPayment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [accounting].[f_getContractorPayment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[f_getContractorPayment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [accounting].[f_getContractorPayment]( @symbol varchar(50), @key varchar(500))
returns varchar(50)
AS
	BEGIN

		DECLARE @extSymbol varchar(100)

		SELECT @extSymbol = xmlValue.value(''(root/entry[localSymbol=sql:variable("@symbol") ]/contractorPayment)[1]'',''varchar(100)'') 
		FROM configuration.Configuration 
		WHERE [key] = @key


	RETURN ISNULL(@extSymbol,'''');

	END







' 
END

GO
