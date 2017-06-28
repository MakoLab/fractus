/*
name=[warehouse].[p_getContainer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
z+VaKRkNxIPlaTkaLAO39Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getContainer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getContainer]
@containerId UNIQUEIDENTIFIER
AS
BEGIN
SELECT (
	SELECT (
		SELECT * 
		FROM warehouse.Container
		WHERE id = @containerId
		FOR XML PATH(''entry''), TYPE
	) 	FOR XML PATH(''container''), TYPE
) 	FOR XML PATH(''root''), TYPE

END
' 
END
GO
