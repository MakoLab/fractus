/*
name=[dbo].[ContractorGroup]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JbOoS2N+ISKPA64hjILrww==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ContractorGroup]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ContractorGroup](
	[groupId] [varchar](500) NULL,
	[megaId] [varchar](500) NULL
) ON [PRIMARY]
END
GO
