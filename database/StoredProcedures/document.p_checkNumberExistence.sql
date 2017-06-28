/*
name=[document].[p_checkNumberExistence]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h/twSbjhpQ75l58mWwuUWw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkNumberExistence]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkNumberExistence]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkNumberExistence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_checkNumberExistence] @xmlVar XML
AS 
	BEGIN
		/*Sprawdzenie numeru dla serii*/
        IF EXISTS ( SELECT  h.id
                    FROM   [document].[CommercialDocumentHeader] h 
							JOIN [document].Series s ON h.seriesId = s.[id]
                            JOIN @xmlVar.nodes(''/root'') AS C ( con ) ON s.seriesValue = con.query(''seriesValue'').value(''.'', ''nvarchar(100)'')
                                                                        AND h.number = con.query(''number'').value(''.'', ''nvarchar(100)'') ) 
                                                                        
			/*Zwrócenie wyników*/                                                                        
            SELECT  ''true''
            FOR     XML PATH(''root''),
                        TYPE 
        ELSE 
            SELECT  ''false''
            FOR     XML PATH(''root''),
                        TYPE 
    END
' 
END
GO
