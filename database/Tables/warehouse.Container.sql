/*
name=[warehouse].[Container]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uhwVQJ8g1kPUJI4Y5PeGfA==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[Container]') AND type in (N'U'))
BEGIN
CREATE TABLE [warehouse].[Container](
	[id] [uniqueidentifier] NOT NULL,
	[symbol] [varchar](50) NOT NULL,
	[containerTypeId] [uniqueidentifier] NOT NULL,
	[xmlLabels] [xml] NULL,
	[xmlMetadata] [xml] NULL,
	[version] [uniqueidentifier] NULL,
	[order] [int] NULL,
	[isActive] [bit] NOT NULL,
	[name] [varchar](50) NULL,
 CONSTRAINT [PK_Container] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[warehouse].[Container]') AND name = N'ind_Container_ContainerType')
CREATE NONCLUSTERED INDEX [ind_Container_ContainerType] ON [warehouse].[Container]
(
	[containerTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Container_ContainerType]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Container]'))
ALTER TABLE [warehouse].[Container]  WITH CHECK ADD  CONSTRAINT [FK_Container_ContainerType] FOREIGN KEY([containerTypeId])
REFERENCES [dictionary].[ContainerType] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[warehouse].[FK_Container_ContainerType]') AND parent_object_id = OBJECT_ID(N'[warehouse].[Container]'))
ALTER TABLE [warehouse].[Container] CHECK CONSTRAINT [FK_Container_ContainerType]
GO
