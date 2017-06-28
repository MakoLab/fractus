
-- --------------------------------------------------
-- Entity Designer DDL Script for SQL Server 2005, 2008, and Azure
-- --------------------------------------------------
-- Date Created: 06/07/2011 13:20:22
-- Generated from EDMX file: D:\Adam\FRACTUS\TFSF2.Net\dotNet\SalesOrdersTracker\TrackerDataAccessLayer\Fractus2Entities.edmx
-- --------------------------------------------------

SET QUOTED_IDENTIFIER OFF;
GO
USE [Fraktusek2];
GO
IF SCHEMA_ID(N'custom') IS NULL EXECUTE(N'CREATE SCHEMA [custom]');
GO

-- --------------------------------------------------
-- Dropping existing FOREIGN KEY constraints
-- --------------------------------------------------


-- --------------------------------------------------
-- Dropping existing tables
-- --------------------------------------------------

IF OBJECT_ID(N'[custom].[SalesOrderTrackerQueueEntries]', 'U') IS NOT NULL
    DROP TABLE [custom].[SalesOrderTrackerQueueEntries];
GO

-- --------------------------------------------------
-- Creating all tables
-- --------------------------------------------------

-- Creating table 'SalesOrderTrackerQueueEntries'
CREATE TABLE [custom].[SalesOrderTrackerQueueEntries] (
    [Id] bigint IDENTITY(1,1) NOT NULL,
    [IsCompleted] bit  NOT NULL,
    [Date] datetime  NOT NULL,
    [SalesOrderId] uniqueidentifier  NOT NULL
);
GO

-- --------------------------------------------------
-- Creating all PRIMARY KEY constraints
-- --------------------------------------------------

-- Creating primary key on [Id] in table 'SalesOrderTrackerQueueEntries'
ALTER TABLE [custom].[SalesOrderTrackerQueueEntries]
ADD CONSTRAINT [PK_SalesOrderTrackerQueueEntries]
    PRIMARY KEY CLUSTERED ([Id] ASC);
GO

-- --------------------------------------------------
-- Creating all FOREIGN KEY constraints
-- --------------------------------------------------

-- --------------------------------------------------
-- Script has ended
-- --------------------------------------------------