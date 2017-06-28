/*
name=[document].[p_getDraft]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
okCM1tYRCqulbucLHAqarA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDraft]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDraft]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDraft]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getDraft]
@xmlVar XML
AS
BEGIN
	DECLARE @id UNIQUEIDENTIFIER,@x xml, @date varchar(50),@data datetime,@dueDate datetime, @i int, @row int
	DECLARE @tmp TABLE (i int identity(1,1), id uniqueidentifier, dueDate datetime, data datetime)

	SELECT @id = @xmlVar.value(''(root/id)[1]'',''char(36)'')
--select @id = ''6986CB9F-2659-49EB-9790-003851D0F2B3'',
	SELECT @date = CONVERT(varchar(50),getdate(),120)
	SELECT @x = (
					SELECT (
						SELECT (
							SELECT *
							FROM document.Draft
							WHERE id = @id
							FOR XML PATH(''entry''), TYPE
						) FOR XML PATH(''draft''), TYPE
					) FOR XML PATH(''root''), TYPE
				)

IF (select CAST(textValue AS datetime) from configuration.Configuration where [key] = ''system.StartDate'') < (SELECT CAST( @x.value(''(/root/draft/entry/dataXml/root/*/issueDate)[1]'',''varchar(50)'') AS datetime))
	BEGIN
--select @x
		SET @x.modify(''replace value of (/root/draft/entry/dataXml/root/*/issueDate/text())[1] with (fn:string(sql:variable("@date"))) '')
		SET @x.modify(''replace value of (/root/draft/entry/dataXml/root/*/eventDate/text())[1] with (fn:string(sql:variable("@date"))) '')
		SET @x.modify(''replace value of (/root/draft/entry/dataXml/root/*/exchangeDate/text())[1] with (fn:string(sql:variable("@date"))) '')
		
		INSERT INTO @tmp( id, dueDate, data)
		SELECT x.value(''id[1]'',''char(36)''),
			   x.value(''dueDate[1]'',''char(36)''), x.value(''date[1]'',''char(36)'')
		FROM @x.nodes(''/root/draft/entry/dataXml/root/*/payments/payment'') AS a(x)
		
		SELECT @row = @@rowcount, @i = 1
		
		DECLARE @dueDateNew varchar(36)

		WHILE @i <= @row
			BEGIN
				SELECT TOP 1 @dueDate = dueDate, @data = [data]  FROM @tmp WHERE i = @i
				
				SET @x.modify(''replace value of (/root/draft/entry/dataXml/root/*/payments/payment[sql:variable("@i")]/date/text())[1] with (fn:string(sql:variable("@date"))) '')
				SELECT @dueDateNew = SUBSTRING(CONVERT(varchar(50),DATEADD(dd,DATEDIFF(dd,@data, @dueDate) ,@date),120), 1, 10)
				SET @x.modify(''replace value of (/root/draft/entry/dataXml/root/*/payments/payment[sql:variable("@i")]/dueDate/text())[1] with (fn:string(sql:variable("@dueDateNew"))) '')

				SELECT @i = @i + 1
			END
	END	
		SELECT @x		
		
END
--exec [document].[p_getDraft] ''<root><id>6C84277C-01CD-4E0D-AB88-37FC7F0ECE7D</id></root>''
/*
exec [document].[p_getDraft] ''
<root>
　<id>A9D1F75C-4990-4BA2-999A-FA8CE3D6F553</id>
</root>''
*/
' 
END
GO
