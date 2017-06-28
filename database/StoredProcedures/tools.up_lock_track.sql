/*
name=[tools].[up_lock_track]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0bm2UE7WPBYL4O1gmfKM0w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[up_lock_track]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[up_lock_track]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[up_lock_track]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
Procedura służy do poszukiwania kwerend blokujących wykonanie innych kwerend
Parametry:
@ilosc_prob - ilość powtórzeń testu na blokowanie
@interwal - odstęp czasu pomiędzy kolejnymi próbami
*/
CREATE PROCEDURE [tools].[up_lock_track] (@ilosc_prob int=1000, @interwal int=10)
AS

SET nocount ON
	/*Tworzenie tabeli do raportu*/
	IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = ''tmp_trace_log_operation'')
	CREATE TABLE [dbo].[tmp_trace_log_operation] (
		[dbid] [smallint] NULL ,
		[objectid] [int] NULL ,
		[number] [smallint] NULL ,
		[encrypted] [bit] NULL ,
		[text] [text] COLLATE Polish_CI_AS NULL ,
		[id] [int] IDENTITY (1, 1) NOT NULL 
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	ELSE    truncate table tmp_trace_log_operation


	DECLARE @Handle binary(20),@spid int, @i int,@opoznienie varchar(8),@hr int,@min int,@sec int

	/*Zmienne opóźnienia*/
	   SELECT @sec = 10
	   SELECT @min = 0
	   SELECT @hr = 0

	/*Opóźnienie pętli*/
	SELECT @opoznienie= right(''0''+ convert(varchar(2),@hr),2) + '':'' + right(''0''+convert(varchar(2),@min),2) + '':'' + right(''0''+convert(varchar(2),@sec),2)

	/*Pętla zbierająca statystyki*/
	SELECT @i = 1
	WHILE (@i <= @ilosc_prob)
	BEGIN

		SELECT DISTINCT @spid = spid
		FROM master.dbo.sysprocesses
		WHERE spid IN (
			SELECT blocked 
			FROM master.dbo.sysprocesses
			)
		AND blocked=0

		SELECT @Handle = sql_handle 
		FROM master.dbo.sysprocesses
		WHERE spid = @spid

		IF @spid >= 50 
		BEGIN
			Insert into tmp_trace_log_operation (dbid,objectid,number,encrypted,text)
			SELECT dbid,objectid,number,encrypted,text FROM ::fn_get_sql(@Handle)
		END

	   SELECT @i = @i + 1
	   WAITFOR DELAY @opoznienie
	END
' 
END
GO
