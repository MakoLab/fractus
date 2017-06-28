/*
name=[warehouse].[p_checkContainerContent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
cIwQP8HBfibaQwFcCVVRZQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_checkContainerContent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_checkContainerContent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_checkContainerContent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_checkContainerContent]
@xmlVar XML
AS
BEGIN

	DECLARE
		@containerId uniqueidentifier,
		@i int, 
		@count int


/*Parametry wejściowe*/
DECLARE @tmp_ TABLE (containerId uniqueidentifier)


INSERT INTO @tmp_
SELECT x.value(''@id'',''char(36)'')
FROM @xmlVar.nodes(''root/container'') AS a(x)




SELECT (
			SELECT t.containerId AS ''@id'', ISNULL(hasContent , ''0'' ) ''@hasContent'' 
			FROM  @tmp_ t
				LEFT JOIN  ( 
						SELECT s.containerId , CASE WHEN ( SUM(s.quantity - ISNULL(x.q,0) )) > 0 THEN ''1'' END AS hasContent
						FROM warehouse.Shift s 
							LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId , sx.containerId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId, sx.containerId ) x ON s.id = x.sourceShiftId
						WHERE (s.quantity - ISNULL(x.q,0)) > 0 AND s.status >= 40 AND s.containerId IS NOT NULL
						GROUP BY s.containerId
						) x ON x.containerId = t.containerId
			FOR XML PATH(''container''),TYPE
	)   FOR XML PATH(''root''),TYPE 


END
' 
END
GO
