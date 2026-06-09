/*
===============================================================================
                            SKYTRACK DATA WAREHOUSE
===============================================================================
 Author      : Akshay M Nair
 Project     : SkyTrack Data Warehouse

 Purpose:
 This script initializes the SkyTrack Data Warehouse environment by
 creating the database and the core schemas required for data ingestion,
 transformation, and analytical processing.

 WARNING:
 This script will recreate the SkyTrackDWH database.
 Any existing data will be permanently removed.
===============================================================================
*/

USE master;
GO

IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'SkyTrackDWH'
)
BEGIN
    ALTER DATABASE SkyTrackDWH
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE SkyTrackDWH;
END
GO

PRINT 'Creating SkyTrackDWH Database...';
GO

CREATE DATABASE SkyTrackDWH;
GO

USE SkyTrackDWH;
GO

PRINT 'Creating Schemas...';
GO

CREATE SCHEMA acquisition;
GO

CREATE SCHEMA processing;
GO

CREATE SCHEMA analytics;
GO

PRINT 'Initialization Completed Successfully.';
GO
