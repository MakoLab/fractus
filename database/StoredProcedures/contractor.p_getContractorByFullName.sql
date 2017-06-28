/*
name=[contractor].[p_getContractorByFullName]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8G3iXcgqk2GYJIhgZPHObQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorByFullName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorByFullName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorByFullName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorByFullName] 
@xmlVar XML
AS
BEGIN
DECLARE 
	@fullName nvarchar(500),
	@contractorId uniqueidentifier,
	@c int


SELECT @fullName = x.query(''fullName'').value(''.'',''varchar(50)'')
FROM @xmlVar.nodes(''root'') as a ( x ) 

SELECT @c = COUNT(id) FROM Contractor.Contractor WITH(NOLOCK) WHERE fullName like @fullName

IF ISNULL(@c,0) <> 1
	SELECT CAST(''<root></root>'' AS XML )
ELSE
	BEGIN
		SELECT @contractorId = id 
		FROM contractor.Contractor c
		WHERE c.fullName like @fullName 

		IF @contractorId IS NOT NULL
			EXEC contractor.p_getContractorData @contractorId	
		ELSE
			SELECT CAST(''<root></root>'' AS XML )
	END
END
' 
END
GO
