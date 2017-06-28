/*
name=[tools].[p_recountFinancialReports]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Snx7z9K3NFgEKArZy4b7bQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_recountFinancialReports]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_recountFinancialReports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_recountFinancialReports]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [tools].[p_recountFinancialReports]  @finanacialRegisterId uniqueidentifier
AS
BEGIN

	DECLARE @firstFinancialReport uniqueidentifier
	DECLARE @i int , @count int, @id uniqueidentifier,@number int, @suma numeric(18,2), @income numeric(18,2), @outcome numeric(18,2)
	DECLARE @tmp TABLE (i int identity(1,1), id uniqueidentifier, number int , data datetime)

	INSERT INTO @tmp(id, number, data)
	SELECT id , number, creationDate
	FROM finance.FinancialReport
	WHERE financialRegisterId =@finanacialRegisterId 
		AND creationDate IS NOT NULL
		AND fullNumber NOT like ''%IMPORT%''
	ORDER BY creationDate, number ASC

	SELECT @count = @@rowcount, @i = 1

	WHILE @i <= @count
		BEGIN
				SELECT @suma = 0, @income = 0, @outcome = 0

				SELECT  @suma = ISNULL(sum(ISNULL(p.amount ,0) * ISNULL(CASE WHEN p.date <= ''2011-12-20 15:03:20.670'' AND p.direction = 0  THEN 1 ELSE  p.direction END,0)) ,0)
				FROM finance.FinancialReport fre 
					LEFT JOIN document.FinancialDocumentHeader fdh  ON fre.id  = fdh.financialReportId
					LEFT JOIN finance.Payment p ON fdh.id = p.financialDocumentHeaderId
				WHERE [status] >= 40 
					AND fre.financialRegisterId = @finanacialRegisterId
					AND fre.creationDate < (SELECT data FROM @tmp WHERE i = @i)

				SELECT  @income = SUM((CASE WHEN (p.amount * CASE WHEN p.date <= ''2011-12-20 15:03:20.670'' AND p.direction = 0  THEN 1 ELSE  p.direction END) > 0 THEN (p.amount * CASE WHEN p.date <= ''2011-12-20 15:03:20.670'' AND p.direction = 0  THEN 1 ELSE  p.direction END) ELSE 0 END )) ,
						@outcome = SUM((CASE WHEN (p.amount * CASE WHEN p.date <= ''2011-12-20 15:03:20.670'' AND p.direction = 0  THEN 1 ELSE  p.direction END) < 0 THEN (p.amount * CASE WHEN p.date <= ''2011-12-20 15:03:20.670'' AND p.direction = 0  THEN 1 ELSE  p.direction END) ELSE 0 END )) 
				FROM dictionary.FinancialRegister re WITH(NOLOCK)
					LEFT JOIN finance.FinancialReport fre WITH(NOLOCK) ON re.id = fre.financialRegisterId
					LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON fre.id  = fdh.financialReportId
					LEFT JOIN finance.Payment p WITH(NOLOCK) ON fdh.id = p.financialDocumentHeaderId
				WHERE fdh.status >= 40 AND fre.id = (SELECT id FROM @tmp WHERE i = @i)
	
				UPDATE finance.FinancialReport 
				SET initialBalance = @suma, 
					incomeAmount = CASE WHEN isClosed = 1 THEN @income ELSE NULL END, 
					outcomeAmount = CASE WHEN isClosed = 1 THEN @outcome ELSE NULL END
				WHERE id = (SELECT id FROM @tmp WHERE i = @i)

		SET @i = @i + 1
		END
END
' 
END
GO
