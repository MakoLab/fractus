/*
name=[warehouse].[ShiftTransaction]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
+6SU0CYIJoLS3tLgbneFdg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[ShiftTransaction]') AND type in (N'U'))
BEGIN
CREATE TABLE [warehouse].[ShiftTransaction](
	[id] [uniqueidentifier] NOT NULL,
	[applicationUserId] [uniqueidentifier] NOT NULL,
	[issueDate] [datetime] NOT NULL,
	[number] [int] IDENTITY(1,1) NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[description] [nvarchar](500) NULL,
	[reasonId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ShiftsTransaction] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
