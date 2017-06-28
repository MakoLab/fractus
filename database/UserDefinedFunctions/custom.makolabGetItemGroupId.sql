/*
name=[custom].[makolabGetItemGroupId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
GpFb+ystcCuYsLeOHOPnBA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabGetItemGroupId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [custom].[makolabGetItemGroupId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabGetItemGroupId]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [custom].[makolabGetItemGroupId] ( @ItemId uniqueidentifier)
RETURNS varchar(254)
AS
BEGIN
    DECLARE @string varchar(254), @X XML;

	SELECT @X = C.xmlValue FROM configuration.Configuration AS C WHERE [C].[KEY] = ''items.group''

	SELECT TOP 1 @string = Q.ItemGroupId
	FROM
	(
		SELECT
			ISNULL((
				SELECT X.value(''(subgroups/group/@id)[1]'', ''varchar(500)'')
				FROM @X.nodes(''//group'') AS A(X)
				WHERE X.value(''@id'', ''varchar(500)'') = IGM.itemGroupId
			), '''')            AS Child
			, IGM.itemGroupId AS ItemGroupId
		FROM item.ItemGroupMembership AS IGM
		WHERE IGM.itemId = @ItemId
	) AS Q
	WHERE Q.Child = ''''

    RETURN @string
END
' 
END

GO
