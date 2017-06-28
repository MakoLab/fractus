/*
name=[reports].[p_getTest]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xey8rt83lNocC2Nun47gbA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getTest]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getTest]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getTest]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [reports].[p_getTest] --''<root/>''
@xmlVar XML
AS
SELECT CAST(
''<root>
  <columns>
    <column label="nazwa" field="@nazwa"/>
    <column label="kod" field="@kod"/>
  </columns>
  <elements>
   <element nazwa="N1" kod="k1"/>
   <element nazwa="N2" kod="k2"/>
   <element nazwa="N3" kod="k3"/>
  </elements>
  <summary>Tekst z podsumowaniem</summary>
</root>'' AS XML) XmlOut
' 
END
GO
