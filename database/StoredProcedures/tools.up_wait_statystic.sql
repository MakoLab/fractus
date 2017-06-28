/*
name=[tools].[up_wait_statystic]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JFZWWDNwy5II5jdEAqVsaQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[up_wait_statystic]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[up_wait_statystic]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[up_wait_statystic]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
Procedura służąca zbieraniu statystyki o wystąpieniach blokowań. 
*/
CREATE proc [tools].[up_wait_statystic] (@ilosc_prob int=10,@interwal int=1,@dt varchar(3)=''m'')
AS

SET nocount ON
	/*Tworzenie tabeli do raportu*/
	IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = ''waitstats'')
	   CREATE table waitstats ([wait type] varchar(80),
		  requests numeric(20,1),
		  [wait time] numeric (20,1),
		  [signal wait time] numeric(20,1),
		  now datetime default getdate())
	ELSE    truncate table waitstats

	/*Czyszczenie statystyk*/
	dbcc sqlperf (waitstats,clear)                             

	DECLARE @i int,@opoznienie varchar(8),@hr int,@min int,@sec int

	/*Zmienne opóźnienia*/
	   SELECT @sec = 0
	   SELECT @min = @interwal % 60
	   SELECT @hr = cast((@interwal / 60) AS int)

	/*Opóźnienie pętli*/
	SELECT @opoznienie= right(''0''+ convert(varchar(2),@hr),2) + '':'' + right(''0''+convert(varchar(2),@min),2) + '':'' + right(''0''+convert(varchar(2),@sec),2)

	/*Pętla zbierająca statystyki*/
	SELECT @i = 1
	WHILE (@i <= @ilosc_prob)
	BEGIN
	   INSERT INTO waitstats ([wait type], requests, [wait time],[signal wait time])
	   EXEC (''dbcc sqlperf(waitstats)'')
	   SELECT @i = @i + 1
	   WAITFOR DELAY @opoznienie
	END
' 
END
GO
