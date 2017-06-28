/*
name=[dictionary].[ItemField]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
zTpgBFRjYPqjtVk+4dR4vg==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[ItemField]') AND type in (N'U'))
BEGIN
CREATE TABLE [dictionary].[ItemField](
	[id] [uniqueidentifier] NOT NULL,
	[itemId] [uniqueidentifier] NULL,
	[name] [varchar](50) NOT NULL,
	[xmlLabels] [xml] NOT NULL,
	[xmlMetadata] [xml] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
	[order] [int] NOT NULL,
 CONSTRAINT [PK_ItemField] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dictionary].[ItemField]') AND name = N'ind_ItemField_Item')
CREATE NONCLUSTERED INDEX [ind_ItemField_Item] ON [dictionary].[ItemField]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_ItemField_Item]') AND parent_object_id = OBJECT_ID(N'[dictionary].[ItemField]'))
ALTER TABLE [dictionary].[ItemField]  WITH CHECK ADD  CONSTRAINT [FK_ItemField_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dictionary].[FK_ItemField_Item]') AND parent_object_id = OBJECT_ID(N'[dictionary].[ItemField]'))
ALTER TABLE [dictionary].[ItemField] CHECK CONSTRAINT [FK_ItemField_Item]
GO
