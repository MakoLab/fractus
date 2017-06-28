/*
name=[dictionary].[p_getShiftFields]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fu5IHsh5UQI0QPUF5fsGnQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getShiftFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getShiftFields]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getShiftFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getShiftFields]
AS 
	/*Budowa XML z polami dodatkowymi Shift*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ShiftField
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''shiftField''),
                              TYPE
                        )
            FOR
              XML PATH(''root''), TYPE
            ) AS returnsXML
' 
END
GO
