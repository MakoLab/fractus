/*
name=[dbo].[p_doc_procedure_list]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
b5uHgnZ3VBrPIGD/7Vtq+g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_doc_procedure_list]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_doc_procedure_list]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_doc_procedure_list]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE p_doc_procedure_list
AS
BEGIN

DECLARE 
@Schema nvarchar(50), 
@SchemaDesc varchar(max),
@lines XML

DECLARE  @tmp_kontent TABLE (id int identity(1,1), tex nvarchar(4000))


/*Nagłówek dokumentacji listy procedur*/
INSERT INTO @tmp_kontent (tex)
SELECT ''
<HTML>
<HEAD>
	<meta http-equiv="Content-Type" content="text/html; charset=windows-1250" />
    <TITLE>Procedury</TITLE>
    <LINK HREF="./style.css" REL="stylesheet" TYPE="text/css">

    <SCRIPT SRC="./script.js"></SCRIPT>
</HEAD>''

/*Body*/
INSERT INTO @tmp_kontent (tex)
SELECT
''<BODY>
    <IMG ID="collapseImage" ALT="Collapse image" SRC="./Images/collapse.gif" STYLE="display: none; height: 0; width: 0;" />
    <IMG ID="expandImage" ALT="Expand image" SRC="./Images/expand.gif" STYLE="display: none; height: 0; width: 0;" />
    <DIV ID="pagetop">
        <DIV ALIGN=CENTER><B><FONT COLOR="Gray">Procedury systemu Fraktus 2</FONT></B> </DIV><HR SIZE="1">
        <P CLASS="apexdoc-header">
            <IMG BORDER="0" CLASS="vmiddle" SRC="./Images/PROC_NEW.gif">&nbsp;Lista procedur</P>
        <P CLASS="makodoc-header-bottom">
	<SPAN onclick="ExpandCollapseAll(toggleAllImage)" style="cursor:default;" onkeypress="ExpandCollapseAll_CheckKey(toggleAllImage)" tabindex="0">
		<IMG ID="toggleAllImage" class="toggleAll" alt="CollapseAll image" src="./Images/collapse.gif"></IMG>
		<LABEL id="collapseAllLabel" for="toggleAllImage" style="display: none;">Collapse All</LABEL>
		<LABEL id="expandAllLabel" for="toggleAllImage" style="display: none;">Expand All</LABEL>
	</SPAN>
	</P>

    </DIV>
'' 
INSERT INTO @tmp_kontent (tex)
SELECT
''
    <DIV ID="pagebody">

        <H2 CLASS="apexdoc-secondary-header">
            <SPAN onclick="ExpandCollapse(''''Procedures'''')" style="cursor:default;"onkeypress="ExpandCollapse_CheckKey(''''Procedures'''')" tabindex="0">
				<IMG id="ProceduresToggle" class="toggle" name="toggleSwitch" alt="Collapse image" src="./Images/collapse.gif"> 
				</IMG>
            Procedures
            </SPAN>
        </H2>
        <DIV ID="ProceduresSection" CLASS="section" STYLE="display: inline;">
        <TABLE>
            <TR CLASS="apexdoc-table-caption">
                <TD WIDTH="18">
                    <!--graphic-->&nbsp;
                </TD>
                <TD>Schema&nbsp;</TD>
                <TD>Opis</TD>
            </TR>
''

DECLARE Prcd CURSOR FOR
	SELECT DISTINCT s.name ,cast(exs.value as varchar(max)) 
	FROM sys.schemas s 
		JOIN  sys.procedures p on s.schema_id = p.schema_id
		LEFT JOIN sys.extended_properties ex  ON ex.major_id = p.object_id
		LEFT JOIN sys.extended_properties exs  ON exs.major_id = s.schema_id
	WHERE p.name LIKE ''p_%'' OR  p.name LIKE ''xp%''


OPEN Prcd
FETCH NEXT FROM Prcd
INTO @Schema, @SchemaDesc

WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO @tmp_kontent (tex)
		SELECT ''
            <TR>
				<TD><IMG CLASS="vmiddle" border="0" SRC="./Images/PROC_NEW.gif"></TD>
				<TD><A HREF="./Procedures/'' + @Schema + ''.htm">'' +  @Schema + ''</A></TD>
				<TD>'' + @SchemaDesc + ''</TD>
			</TR>		

''
		FETCH NEXT FROM Prcd
		INTO @Schema, @SchemaDesc
	END


CLOSE Prcd
DEALLOCATE Prcd


		INSERT INTO @tmp_kontent (tex)
		SELECT ''
      </TABLE>
		<BR>
		<BR>

        <HR SIZE="1"><DIV ALIGN=CENTER><B> <FONT COLOR="Gray">Makolab S.A.</FONT></B></DIV>
    </DIV>
</BODY>
</HTML>
''


SELECT @lines = (
				SELECT tex element
				FROM	@tmp_kontent 
				ORDER BY id
				FOR XML PATH(''element''), TYPE
				)

--SELECT @lines
--
-- p_doc_procedure_list
--SELECT x.query(''element'').value(''.'',''varchar(max)'')
--FROM @lines.nodes(''/root'') a(x)

EXEC p_createDokFile @lines, '''', ''''

END' 
END
GO
