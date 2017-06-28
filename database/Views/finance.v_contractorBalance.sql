/*
name=[finance].[v_contractorBalance]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
zTUxJgSZldHF0XkOQTYxRw==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[finance].[v_contractorBalance]'))
DROP VIEW [finance].[v_contractorBalance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[finance].[v_contractorBalance]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [finance].[v_contractorBalance]
AS
SELECT contractorId  , SUM( amount * direction ) balance
FROM finance.Payment
WHERE contractorId IS  NOT NULL 
GROUP BY contractorId
' 
GO
