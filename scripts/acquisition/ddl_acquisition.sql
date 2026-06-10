/*
===============================================================================
Project     : SkyTrack Data Warehouse
Layer       : Acquisition Layer
Script      : Create Acquisition Tables
Author      : Akshay M Nair
Created On  : 2026-06-10

Description :
This script creates the Acquisition Layer tables for the SkyTrack Data
Warehouse project.

The Acquisition Layer serves as the landing zone for source data and stores
raw airline datasets without applying business transformations or analytical
modelling.

Data Domains :
    Master Data
    - mast_airports_raw
    - mast_employees_raw
    - mast_flights_raw

    Service Data
    - serv_passengers_raw
    - serv_tickets_raw

Notes :
    - Tables are recreated during development.
    - Source files are loaded directly from CSV datasets.
    - Primary Keys and Foreign Keys are intentionally omitted.
    - Data cleansing and transformations are handled in the Processing Layer.

===============================================================================
*/
USE SkyTrack_DWH;
GO

-- Airports
IF OBJECT_ID('acquisition.airports_raw', 'U') IS NOT NULL
    DROP TABLE acquisition.airports_raw;

CREATE TABLE acquisition.mast_airports_raw
(
    airport_id      VARCHAR(20),
    iata_code       VARCHAR(10),
    airport_name    NVARCHAR(200),
    city            NVARCHAR(100),
    country         NVARCHAR(100),
    timezone        NVARCHAR(100)
);
GO

-- Employees
IF OBJECT_ID('acquisition.employees_raw', 'U') IS NOT NULL
    DROP TABLE acquisition.employees_raw;

CREATE TABLE acquisition.mast_employees_raw
(
    employee_id         VARCHAR(20),
    first_name          NVARCHAR(100),
    last_name           NVARCHAR(100),
    role                NVARCHAR(50),
    base_airport_id     VARCHAR(20),
    hire_date           DATE,
    email               NVARCHAR(255)
);
GO

-- Passengers
IF OBJECT_ID('acquisition.passengers_raw', 'U') IS NOT NULL
    DROP TABLE acquisition.passengers_raw;

CREATE TABLE acquisition.serv_passengers_raw
(
    passenger_id        VARCHAR(20),
    first_name          NVARCHAR(100),
    last_name           NVARCHAR(100),
    gender              CHAR(1),
    dob                 DATE,
    email               NVARCHAR(255),
    phone               VARCHAR(50),
    nationality         NVARCHAR(100)
);
GO

-- Flights
IF OBJECT_ID('acquisition.flights_raw', 'U') IS NOT NULL
    DROP TABLE acquisition.flights_raw;

CREATE TABLE acquisition.mast_flights_raw
(
    flight_id               VARCHAR(20),
    airline_code            VARCHAR(20),
    flight_no               VARCHAR(20),
    origin_airport_id       VARCHAR(20),
    destination_airport_id  VARCHAR(20),
    departure_time          DATETIME2,
    arrival_time            DATETIME2,
    aircraft_type           NVARCHAR(100),
    status                  NVARCHAR(50),
    pilot_id                VARCHAR(20),
    co_pilot_id             VARCHAR(20)
);
GO

-- Tickets
IF OBJECT_ID('acquisition.tickets_raw', 'U') IS NOT NULL
    DROP TABLE acquisition.tickets_raw;

CREATE TABLE acquisition.serv_tickets_raw
(
    ticket_id       VARCHAR(20),
    ticket_no       VARCHAR(20),
    passenger_id    VARCHAR(20),
    flight_id       VARCHAR(20),
    seat            VARCHAR(10),
    class           NVARCHAR(50),
    price_usd       DECIMAL(10,2),
    booking_date    DATE,
    status          NVARCHAR(50)
);
GO
