/*
name=[dbo].[f_getContractorGroupAttribute]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dlT3CeqXU+KqSUqMAKS1eg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getContractorGroupAttribute]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_getContractorGroupAttribute]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getContractorGroupAttribute]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_getContractorGroupAttribute]
( @id uniqueidentifier, @attr varchar(100) )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @string varchar(500), @x xml

SELECT @x = xmlValue
FROM configuration.Configuration
WHERE [key] = ''contractors.group''

if @attr = ''SalesLockAttribute_MaxDebtAmount''
SELECT @string = nullif(x.value(''(attributes/attribute[@name="SalesLockAttribute_MaxDebtAmount"])[1]'',''varchar(500)''),''NaN'')
FROM @x.nodes(''//group'') as a(x)
WHERE x.value(''@id'',''varchar(500)'') = @id

if @attr = ''SalesLockAttribute_MaxDocumentDebtAmount''
SELECT @string = nullif(x.value(''(attributes/attribute[@name="SalesLockAttribute_MaxDocumentDebtAmount"])[1]'',''varchar(500)''),''NaN'')
FROM @x.nodes(''//group'') as a(x)
WHERE x.value(''@id'',''varchar(500)'') = @id

if @attr = ''SalesLockAttribute_MaxOverdueDays''
SELECT @string = nullif(x.value(''(attributes/attribute[@name="SalesLockAttribute_MaxOverdueDays"])[1]'',''varchar(500)''),''NaN'') 
FROM @x.nodes(''//group'') as a(x)
WHERE x.value(''@id'',''varchar(500)'') = @id

if @attr = ''SalesLockAttribute_AllowCashPayment''
SELECT @string = nullif(x.value(''(attributes/attribute[@name="SalesLockAttribute_AllowCashPayment"])[1]'',''varchar(500)''),''NaN'')
FROM @x.nodes(''//group'') as a(x)
WHERE x.value(''@id'',''varchar(500)'') = @id

RETURN @string
END
' 
END

GO
