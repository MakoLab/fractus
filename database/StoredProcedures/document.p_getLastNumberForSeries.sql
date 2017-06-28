/*
name=[document].[p_getLastNumberForSeries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JFZuLVn/5jRL0RK40KiGuw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getLastNumberForSeries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getLastNumberForSeries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getLastNumberForSeries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getLastNumberForSeries]
@xmlVar XML
AS
DECLARE @number INT,
	@seriesId UNIQUEIDENTIFIER,
	@numberSettingId UNIQUEIDENTIFIER,
	@seriesValue nvarchar(500)
    BEGIN
	
		SELECT @numberSettingId = con.query(''numberSettingId'').value(''.'', ''char(36)''),
			@seriesValue = con.query(''seriesValue'').value(''.'', ''nvarchar(500)'')
		FROM @xmlVar.nodes(''/root'') AS C ( con )


		/*Pobranie aktualnego numeru dla serii numeracji*/
	    SELECT  @number = ISNULL(lastNumber + 1 ,1)
        FROM    [document].Series WITH(NOLOCK)
			JOIN @xmlVar.nodes(''/root'') AS C ( con ) ON Series.numberSettingId = @numberSettingId
            AND Series.seriesValue = @seriesValue

		 SELECT ISNULL(@number,1) 	
    	 FOR     XML PATH(''root''),TYPE 
		
		

    END
' 
END
GO
