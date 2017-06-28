/*
name=[item].[ItemGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nl3zh5N7Lj0IPWfOCbxk8A==
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[ItemGroupMembership]') AND type in (N'U'))
BEGIN
CREATE TABLE [item].[ItemGroupMembership](
	[id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[itemId] [uniqueidentifier] NOT NULL,
	[itemGroupId] [uniqueidentifier] NOT NULL,
	[version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ItemGroupMembership] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[item].[ItemGroupMembership]') AND name = N'ind_ItemGroupMembership_Item')
CREATE NONCLUSTERED INDEX [ind_ItemGroupMembership_Item] ON [item].[ItemGroupMembership]
(
	[itemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[item].[DF_ItemGroupMembership_id]') AND type = 'D')
BEGIN
ALTER TABLE [item].[ItemGroupMembership] ADD  CONSTRAINT [DF_ItemGroupMembership_id]  DEFAULT (newid()) FOR [id]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemGroupMembership_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemGroupMembership]'))
ALTER TABLE [item].[ItemGroupMembership]  WITH CHECK ADD  CONSTRAINT [FK_ItemGroupMembership_Item] FOREIGN KEY([itemId])
REFERENCES [item].[Item] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[item].[FK_ItemGroupMembership_Item]') AND parent_object_id = OBJECT_ID(N'[item].[ItemGroupMembership]'))
ALTER TABLE [item].[ItemGroupMembership] CHECK CONSTRAINT [FK_ItemGroupMembership_Item]
GO
