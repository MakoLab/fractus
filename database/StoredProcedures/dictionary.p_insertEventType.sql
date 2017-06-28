/*
name=[dictionary].[p_insertEventType]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bD1w1nVM7y/vlmxWdHwOmg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertEventType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_insertEventType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_insertEventType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE dictionary.p_insertEventType 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
INSERT INTO dictionary.EventType ([id],  [name],  [value],  [xmlLabels],  [xmlMetadata],  [version])   
SELECT 
NULLIF(x.value(''(id)[1]'',''uniqueidentifier'') ,''''),  
NULLIF(x.value(''(name)[1]'',''varchar(50)'') ,''''),  
NULLIF(x.value(''(value)[1]'',''int'') ,''''),  
x.query(''xmlLabels/*''),  
x.query(''xmlMetadata/*''),  
NULLIF(x.value(''(version)[1]'',''uniqueidentifier'') ,'''')
FROM @xmlVar.nodes(''root'') as a(x) 
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:EventType ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
END
' 
END
GO
