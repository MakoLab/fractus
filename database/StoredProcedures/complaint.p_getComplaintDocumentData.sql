/*
name=[complaint].[p_getComplaintDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KgtSdAnV1OHasnJhOsZU+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_getComplaintDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_getComplaintDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_getComplaintDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [complaint].[p_getComplaintDocumentData] 
@complaintDocumentHeaderId uniqueidentifier
AS
BEGIN

DECLARE @tmp TABLE (id uniqueidentifier)

	INSERT INTO @tmp (id) 
	SELECT   contractorId
	FROM     [complaint].ComplaintDocumentHeader
	WHERE    id = @complaintDocumentHeaderId
    UNION                                                  
    SELECT    issuerContractorId
	FROM     [complaint].ComplaintDocumentHeader
	WHERE    id = @complaintDocumentHeaderId
    UNION
	SELECT  relatedContractorId
	FROM    contractor.ContractorRelation
	WHERE   ContractorId in (	SELECT   contractorId
								FROM     [complaint].ComplaintDocumentHeader
								WHERE    id = @complaintDocumentHeaderId
								UNION                                                  
								SELECT    issuerContractorId
								FROM     [complaint].ComplaintDocumentHeader
								WHERE    id = @complaintDocumentHeaderId
							)
													




SELECT (
	SELECT    ( SELECT    ( 
							SELECT    s.*
							FROM      complaint.ComplaintDocumentHeader  s 
							WHERE     s.id = @complaintDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDocumentHeader''), TYPE
			   ),
			   (SELECT   (
							SELECT    e.*
							FROM      complaint.ComplaintDocumentLine e
							WHERE     e.complaintDocumentHeaderId = @complaintDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDocumentLine''), TYPE
			   ),
   			   (SELECT   (
							SELECT    e.*
							FROM      complaint.ComplaintDecision e
							WHERE     e.complaintDocumentLineId IN (SELECT id FROM complaint.ComplaintDocumentLine WHERE complaintDocumentHeaderId = @complaintDocumentHeaderId)
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDecision''), TYPE
			   ),
			   (SELECT   (
							SELECT    e.*
							FROM      document.DocumentAttrValue e
							WHERE     e.complaintDocumentHeaderId  = @complaintDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''documentAttrValue''), TYPE
			   ),
			                               ( SELECT    (	SELECT    *
															FROM      [contractor].Contractor
															WHERE     id IN ( SELECT id FROM @tmp )
		
                                        FOR XML PATH(''entry''), TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),
                                  TYPE
                            ), 
						( SELECT ( 
								SELECT * 
								FROM contractor.ContractorAccount
                                WHERE  contractorId IN ( SELECT id FROM @tmp )
								FOR XML PATH(''entry''), TYPE
										 )
                            FOR XML PATH(''contractorAccount''), TYPE                    
						),
						( SELECT    (  SELECT    *
									   FROM    contractor.ContractorRelation
									   WHERE   ContractorId IN ( SELECT id FROM @tmp )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAddress
                                          WHERE     contractorId IN ( SELECT id FROM @tmp )
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR
                              XML PATH(''contractorAddress''),
                                  TYPE
                            ),

			                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAttrValue
                                          WHERE     contractorId IN ( SELECT id FROM @tmp )
										  FOR XML PATH(''entry''), TYPE
                                        )
                            FOR
                              XML PATH(''contractorAttrValue''),
                                  TYPE
                            ),
			   
   			   (SELECT   (
							SELECT    e.*
							FROM      document.DocumentRelation e
							WHERE     @complaintDocumentHeaderId IN (e.firstComplaintDocumentHeaderId, e.secondComplaintDocumentHeaderId)
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''documentRelation''), TYPE
			   )			   
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO
