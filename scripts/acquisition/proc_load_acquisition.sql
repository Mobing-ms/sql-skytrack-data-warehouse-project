/*
===============================================================================
Project     : SkyTrack Data Warehouse
Layer       : Acquisition Layer
Procedure   : acquisition.load_acquisition

Description :
This stored procedure performs the data ingestion process for the
Acquisition Layer of the SkyTrack Data Warehouse.

The procedure extracts source data from CSV files and loads it into
the raw acquisition tables using SQL Server BULK INSERT operations.

Data Sources :
    Master Data
    - flights_large.csv
    - employees_large.csv
    - airports_large.csv

    Service Data
    - passengers_large.csv
    - tickets_large.csv

Process Flow :
    1. Truncate existing raw tables.
    2. Extract data from source CSV files.
    3. Load data into acquisition tables.
    4. Capture individual table load durations.
    5. Capture total ETL batch execution duration.
    6. Log execution progress through PRINT statements.
    7. Handle and report errors using TRY...CATCH blocks.

Target Tables :
    acquisition.mast_flights_raw
    acquisition.mast_employees_raw
    acquisition.mast_airports_raw
    acquisition.serv_passengers_raw
    acquisition.serv_tickets_raw

Monitoring Features :
    - Individual table load duration tracking
    - Total ETL batch duration tracking
    - Load status logging
    - Error reporting and diagnostics

Load Strategy :
    Full Refresh Load

Notes :
    - Existing data is removed before every load cycle.
    - Source files are expected to contain header rows.
    - Acquisition tables store source data prior to cleansing,
      standardization and transformation.
    - Data quality validation and business transformations are
      performed in the Processing Layer.

===============================================================================
*/
CREATE OR ALTER PROCEDURE acquisition.load_acquisition
AS
BEGIN
    DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
    SET @batch_start_time = GETDATE();
    BEGIN TRY
        PRINT '============================================================';
        PRINT '              SKYTRACK DWH - ACQUISITION LAYER';
        PRINT '============================================================';

        PRINT '';
        PRINT '**************** MASTER DATA LOAD ****************';

        PRINT 'Loading: mast_flights_raw'

        SET @start_time = GETDATE();
        TRUNCATE TABLE acquisition.mast_flights_raw;

        BULK INSERT acquisition.mast_flights_raw
        FROM 'C:\Users\aksha\Downloads\Data Warehouse\Skytrack Airlines Data Warehouse-updated\Datasets\Master-Data\flights_large.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Completed: mast_flights_raw';
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' seconds';
        PRINT '';
        PRINT '';
        PRINT 'Loading: mast_employees_raw';
        SET @start_time = GETDATE();
        TRUNCATE TABLE acquisition.mast_employees_raw;

        BULK INSERT acquisition.mast_employees_raw
        FROM 'C:\Users\aksha\Downloads\Data Warehouse\Skytrack Airlines Data Warehouse-updated\Datasets\Master-Data\employees_large.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Completed: mast_employees_raw';
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' seconds';
        PRINT '';
        PRINT '';
        PRINT 'Loading: mast_airports_raw';
        SET @start_time = GETDATE();
        TRUNCATE TABLE acquisition.mast_airports_raw;

        BULK INSERT acquisition.mast_airports_raw
        FROM 'C:\Users\aksha\Downloads\Data Warehouse\Skytrack Airlines Data Warehouse-updated\Datasets\Master-Data\airports_large.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Completed: mast_airports_raw';
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' seconds';

        PRINT '';
        PRINT '**************** SERVICE DATA LOAD ****************';

        PRINT 'Loading: serv_passengers_raw';
        SET @start_time = GETDATE();
        TRUNCATE TABLE acquisition.serv_passengers_raw;

        BULK INSERT acquisition.serv_passengers_raw
        FROM 'C:\Users\aksha\Downloads\Data Warehouse\Skytrack Airlines Data Warehouse-updated\Datasets\Service-Data\passengers_large.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Completed: serv_passengers_raw';
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' seconds';

        PRINT '';
        PRINT '';
        PRINT 'Loading: serv_tickets_raw';

        SET @start_time = GETDATE();
        TRUNCATE TABLE acquisition.serv_tickets_raw;

        BULK INSERT acquisition.serv_tickets_raw
        FROM 'C:\Users\aksha\Downloads\Data Warehouse\Skytrack Airlines Data Warehouse-updated\Datasets\Service-Data\tickets_large.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Completed: serv_tickets_raw';
        PRINT '>>Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' seconds';
        SET @batch_end_time = GETDATE();
        PRINT '';
        PRINT '============================================================';
        PRINT '       ACQUISITION LAYER LOADING COMPLETED SUCCESSFULLY';
        PRINT '============================================================';

        PRINT '>>Total batch duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time)AS NVARCHAR) + ' seconds'

    END TRY
    BEGIN CATCH
        PRINT'=============================================='
        PRINT'ERROR OCCURED DURING LOADING ACQUISITION LAYER'
        PRINT'Error Message: ' + ERROR_MESSAGE();
        PRINT'Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT'=============================================='
    END CATCH
END;
GO
