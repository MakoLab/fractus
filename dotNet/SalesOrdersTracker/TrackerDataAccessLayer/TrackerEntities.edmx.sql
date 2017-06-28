
-- --------------------------------------------------
-- Entity Designer DDL Script for SQL Server 2005, 2008, and Azure
-- --------------------------------------------------
-- Date Created: 06/07/2011 14:14:15
-- Generated from EDMX file: D:\Adam\FRACTUS\TFSF2.Net\dotNet\SalesOrdersTracker\TrackerDataAccessLayer\TrackerEntities.edmx
-- --------------------------------------------------

SET QUOTED_IDENTIFIER OFF;
GO
USE [Fraktusek2];
GO
IF SCHEMA_ID(N'dbo') IS NULL EXECUTE(N'CREATE SCHEMA [custom]');
GO

-- --------------------------------------------------
-- Dropping existing FOREIGN KEY constraints
-- --------------------------------------------------


-- --------------------------------------------------
-- Dropping existing tables
-- --------------------------------------------------


-- --------------------------------------------------
-- Creating all tables
-- --------------------------------------------------

-- Creating table 'MessageReferences'
CREATE TABLE [custom].[MessageReferences] (
    [Id] uniqueidentifier  NOT NULL,
    [MessageId] uniqueidentifier  NOT NULL,
    [SalesOrderId] uniqueidentifier  NOT NULL,
    [SalesOrderDetailsId] uniqueidentifier  NOT NULL
);
GO

-- Creating table 'SalesOrderSnapshots'
CREATE TABLE [custom].[SalesOrderSnapshots] (
    [Id] uniqueidentifier  NOT NULL,
    [Number] nvarchar(max)  NULL,
    [Status] int  NOT NULL,
    [RegistrationDate] datetime  NOT NULL,
    [Value] decimal(18,0)  NOT NULL,
    [FittingDate] datetime  NULL,
    [Remarks] nvarchar(max)  NULL,
    [Contractor_FullName] nvarchar(max)  NOT NULL,
    [Contractor_Address] nvarchar(max)  NULL,
    [Contractor_City] nvarchar(max)  NULL,
    [Contractor_Email] nvarchar(max)  NULL,
    [Contractor_Phone] nvarchar(max)  NULL,
    [Contractor_IsAps] bit  NOT NULL,
    [Contractor_Login] nvarchar(max)  NULL,
    [Contractor_Password] nvarchar(max)  NULL,
    [Contractor_Type] int  NOT NULL,
    [SalesType] int  NOT NULL,
    [ProductionOrderNumber] nvarchar(max)  NULL
);
GO

-- Creating table 'SalesOrderEvents'
CREATE TABLE [custom].[SalesOrderEvents] (
    [Id] uniqueidentifier  NOT NULL,
    [SalesOrderDetailsId] uniqueidentifier  NOT NULL,
    [Type] int  NOT NULL,
    [Date] datetime  NULL,
    [Number] nvarchar(max)  NULL,
    [Value] decimal(18,0)  NULL,
    [ContractNumber] nvarchar(max)  NOT NULL
);
GO

-- --------------------------------------------------
-- Creating all PRIMARY KEY constraints
-- --------------------------------------------------

-- Creating primary key on [Id] in table 'MessageReferences'
ALTER TABLE [custom].[MessageReferences]
ADD CONSTRAINT [PK_MessageReferences]
    PRIMARY KEY CLUSTERED ([Id] ASC);
GO

-- Creating primary key on [Id] in table 'SalesOrderSnapshots'
ALTER TABLE [custom].[SalesOrderSnapshots]
ADD CONSTRAINT [PK_SalesOrderSnapshots]
    PRIMARY KEY CLUSTERED ([Id] ASC);
GO

-- Creating primary key on [Id] in table 'SalesOrderEvents'
ALTER TABLE [custom].[SalesOrderEvents]
ADD CONSTRAINT [PK_SalesOrderEvents]
    PRIMARY KEY CLUSTERED ([Id] ASC);
GO

-- --------------------------------------------------
-- Creating all FOREIGN KEY constraints
-- --------------------------------------------------

-- Creating foreign key on [SalesOrderDetailsId] in table 'SalesOrderEvents'
ALTER TABLE [custom].[SalesOrderEvents]
ADD CONSTRAINT [FK_SalesOrderDetailsSalesOrderEvent]
    FOREIGN KEY ([SalesOrderDetailsId])
    REFERENCES [custom].[SalesOrderSnapshots]
        ([Id])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_SalesOrderDetailsSalesOrderEvent'
CREATE INDEX [IX_FK_SalesOrderDetailsSalesOrderEvent]
ON [custom].[SalesOrderEvents]
    ([SalesOrderDetailsId]);
GO

-- Creating foreign key on [SalesOrderDetailsId] in table 'MessageReferences'
ALTER TABLE [custom].[MessageReferences]
ADD CONSTRAINT [FK_MessageReferenceSalesOrderDetails]
    FOREIGN KEY ([SalesOrderDetailsId])
    REFERENCES [custom].[SalesOrderSnapshots]
        ([Id])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_MessageReferenceSalesOrderDetails'
CREATE INDEX [IX_FK_MessageReferenceSalesOrderDetails]
ON [custom].[MessageReferences]
    ([SalesOrderDetailsId]);
GO

-- --------------------------------------------------
-- Script has ended
-- --------------------------------------------------