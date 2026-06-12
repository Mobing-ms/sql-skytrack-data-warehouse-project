/*
====================================================================
SKYTRACK DATA WAREHOUSE - ANALYTICS LAYER VIEWS
====================================================================

Description:
This script creates the Analytics Layer views used for reporting
and business intelligence in the SkyTrack Data Warehouse project.

Views Included:
1. dim_employees
   - Employee dimension with derived employee status tiers
     (Bronze, Silver, Gold, Platinum).

2. dim_passengers
   - Passenger dimension with loyalty classification based on
     ticket activity and total ticket count.

3. dim_airport
   - Airport reference dimension containing airport details
     and geographical information.

4. fact_booking
   - Booking analytics view with derived business metrics such as:
     • Booking Segment
     • Loyalty Points Earned
     • Booking Lead Days
     • Booking Type

5. fact_flight
   - Flight analytics view containing operational metrics such as:
     • Flight Duration
     • Flight Type
     • Status Category

6. fact_route_performance
   - Route-level performance analytics including:
     • Total Flights
     • Total Bookings
     • Total Revenue
     • Average Ticket Price
     • Average Flight Duration
     • Route Classification

Purpose:
To provide business-ready analytical datasets for Power BI
dashboards, KPI reporting, route analysis, passenger insights,
employee analytics, and revenue performance monitoring.

Project:
SkyTrack Airline Data Warehouse

Author:
Akshay M Nair

====================================================================
*/

USE SkyTrack_DWH;
GO


CREATE OR ALTER VIEW analytics.dim_employees
AS
SELECT
    employee_id,
    first_name,
    last_name,
    role,
    base_airport_id,
    hire_date,
    email,

    CASE
        WHEN years_of_service <= 2 THEN 'Bronze'
        WHEN years_of_service <= 5 THEN 'Silver'
        WHEN years_of_service <= 10 THEN 'Gold'
        ELSE 'Platinum'
    END AS employee_status

FROM processing.mast_employees;
GO

CREATE OR ALTER VIEW analytics.dim_passengers
AS
SELECT
    p.passenger_id,
    p.first_name,
    p.last_name,
    p.gender,
    p.dob AS date_of_birth,
    p.nationality,

    CASE
        WHEN ISNULL(t.total_tickets, 0) >= 20 THEN 'Platinum'
        WHEN ISNULL(t.total_tickets, 0) >= 10 THEN 'Gold'
        WHEN ISNULL(t.total_tickets, 0) >= 5 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_status,

    p.email,
    p.phone AS phone_number,

    ISNULL(t.total_tickets, 0) AS total_tickets

FROM processing.serv_passengers p
LEFT JOIN
(
    SELECT
        passenger_id,
        COUNT(*) AS total_tickets
    FROM processing.serv_tickets
    GROUP BY passenger_id
) t
    ON p.passenger_id = t.passenger_id;
GO

CREATE OR ALTER VIEW analytics.dim_airport
AS
SELECT
    airport_id,
    iata_code,
    airport_name,
    city,
    country,
    timezone
FROM processing.mast_airports;
GO

CREATE OR ALTER VIEW analytics.fact_booking
AS
SELECT
    t.ticket_id,
    t.passenger_id,
    t.flight_id,
    t.booking_date,
    t.class,
    t.price_usd,

    CASE
        WHEN t.price_usd >= 2000 THEN 'Premium'
        WHEN t.price_usd >= 1000 THEN 'Standard'
        ELSE 'Budget'
    END AS booking_segment,

    CASE
        WHEN t.class = 'First' THEN t.price_usd * 3
        WHEN t.class = 'Business' THEN t.price_usd * 2
        WHEN t.class = 'Premium Economy' THEN t.price_usd * 1.5
        ELSE t.price_usd
    END AS loyalty_points_earned,

    -- Business Metric 3
    DATEDIFF(DAY, t.booking_date, CAST(f.departure_time AS DATE))
    AS booking_lead_days,

    -- Business Metric 4
    CASE
        WHEN DATEDIFF(DAY, t.booking_date, CAST(f.departure_time AS DATE)) >= 30
            THEN 'Advance Booking'
        WHEN DATEDIFF(DAY, t.booking_date, CAST(f.departure_time AS DATE)) >= 7
            THEN 'Regular Booking'
        ELSE 'Last Minute'
    END AS booking_type

FROM processing.serv_tickets t
JOIN processing.mast_flights f
    ON t.flight_id = f.flight_id
JOIN processing.mast_airports oa
    ON f.origin_airport_id = oa.airport_id
JOIN processing.mast_airports da
    ON f.destination_airport_id = da.airport_id;
GO

CREATE OR ALTER VIEW analytics.fact_flight
AS
SELECT
    f.flight_id,
    f.flight_no,
    f.airline_code,

    f.origin_airport_id,
    oa.airport_name AS origin_airport,
    oa.country AS origin_country,

    f.destination_airport_id,
    da.airport_name AS destination_airport,
    da.country AS destination_country,

    f.departure_time,
    f.arrival_time,

    f.aircraft_type,
    f.status,

    DATEDIFF(MINUTE, f.departure_time, f.arrival_time) / 60.0
        AS flight_duration_hours,

    CASE
        WHEN f.status = 'Completed' THEN 'Successful'
        WHEN f.status = 'Delayed' THEN 'Operational Issue'
        WHEN f.status = 'Cancelled' THEN 'Operational Issue'
        ELSE 'Other'
    END AS status_category,

    CASE
        WHEN DATEDIFF(MINUTE, f.departure_time, f.arrival_time) < 180
            THEN 'Short Haul'
        WHEN DATEDIFF(MINUTE, f.departure_time, f.arrival_time) < 360
            THEN 'Medium Haul'
        ELSE 'Long Haul'
    END AS flight_type

FROM processing.mast_flights f
LEFT JOIN processing.mast_airports oa
    ON f.origin_airport_id = oa.airport_id
LEFT JOIN processing.mast_airports da
    ON f.destination_airport_id = da.airport_id;
GO

CREATE OR ALTER VIEW analytics.fact_route_performance
AS
SELECT
    f.origin_airport_id,
    oa.airport_name AS origin_airport,
    oa.country AS origin_country,

    f.destination_airport_id,
    da.airport_name AS destination_airport,
    da.country AS destination_country,

    COUNT(DISTINCT f.flight_id) AS total_flights,

    COUNT(DISTINCT t.ticket_id) AS total_bookings,

    SUM(t.price_usd) AS total_revenue,

    AVG(t.price_usd) AS avg_ticket_price,

    AVG(
        DATEDIFF
        (
            MINUTE,
            f.departure_time,
            f.arrival_time
        )
    ) / 60.0 AS avg_flight_duration_hours,

    CASE
        WHEN oa.country = da.country
            THEN 'Domestic'
        ELSE 'International'
    END AS route_type

FROM processing.mast_flights f

LEFT JOIN processing.serv_tickets t
    ON f.flight_id = t.flight_id

LEFT JOIN processing.mast_airports oa
    ON f.origin_airport_id = oa.airport_id

LEFT JOIN processing.mast_airports da
    ON f.destination_airport_id = da.airport_id

GROUP BY
    f.origin_airport_id,
    oa.airport_name,
    oa.country,
    f.destination_airport_id,
    da.airport_name,
    da.country;
GO


USE SkyTrack_DWH;
GO


CREATE OR ALTER VIEW analytics.dim_employees
AS
SELECT
    employee_id,
    first_name,
    last_name,
    role,
    base_airport_id,
    hire_date,
    email,

    CASE
        WHEN years_of_service <= 2 THEN 'Bronze'
        WHEN years_of_service <= 5 THEN 'Silver'
        WHEN years_of_service <= 10 THEN 'Gold'
        ELSE 'Platinum'
    END AS employee_status

FROM processing.mast_employees;
GO

CREATE OR ALTER VIEW analytics.dim_passengers
AS
SELECT
    p.passenger_id,
    p.first_name,
    p.last_name,
    p.gender,
    p.dob AS date_of_birth,
    p.nationality,

    CASE
        WHEN ISNULL(t.total_tickets, 0) >= 20 THEN 'Platinum'
        WHEN ISNULL(t.total_tickets, 0) >= 10 THEN 'Gold'
        WHEN ISNULL(t.total_tickets, 0) >= 5 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_status,

    p.email,
    p.phone AS phone_number,

    ISNULL(t.total_tickets, 0) AS total_tickets

FROM processing.serv_passengers p
LEFT JOIN
(
    SELECT
        passenger_id,
        COUNT(*) AS total_tickets
    FROM processing.serv_tickets
    GROUP BY passenger_id
) t
    ON p.passenger_id = t.passenger_id;
GO

CREATE OR ALTER VIEW analytics.dim_airport
AS
SELECT
    airport_id,
    iata_code,
    airport_name,
    city,
    country,
    timezone
FROM processing.mast_airports;
GO

CREATE OR ALTER VIEW analytics.fact_booking
AS
SELECT
    t.ticket_id,
    t.passenger_id,
    t.flight_id,
    t.booking_date,
    t.class,
    t.price_usd,

    CASE
        WHEN t.price_usd >= 2000 THEN 'Premium'
        WHEN t.price_usd >= 1000 THEN 'Standard'
        ELSE 'Budget'
    END AS booking_segment,

    CASE
        WHEN t.class = 'First' THEN t.price_usd * 3
        WHEN t.class = 'Business' THEN t.price_usd * 2
        WHEN t.class = 'Premium Economy' THEN t.price_usd * 1.5
        ELSE t.price_usd
    END AS loyalty_points_earned,

    -- Business Metric 3
    DATEDIFF(DAY, t.booking_date, CAST(f.departure_time AS DATE))
    AS booking_lead_days,

    -- Business Metric 4
    CASE
        WHEN DATEDIFF(DAY, t.booking_date, CAST(f.departure_time AS DATE)) >= 30
            THEN 'Advance Booking'
        WHEN DATEDIFF(DAY, t.booking_date, CAST(f.departure_time AS DATE)) >= 7
            THEN 'Regular Booking'
        ELSE 'Last Minute'
    END AS booking_type

FROM processing.serv_tickets t
JOIN processing.mast_flights f
    ON t.flight_id = f.flight_id
JOIN processing.mast_airports oa
    ON f.origin_airport_id = oa.airport_id
JOIN processing.mast_airports da
    ON f.destination_airport_id = da.airport_id;
GO

CREATE OR ALTER VIEW analytics.fact_flight
AS
SELECT
    f.flight_id,
    f.flight_no,
    f.airline_code,

    f.origin_airport_id,
    oa.airport_name AS origin_airport,
    oa.country AS origin_country,

    f.destination_airport_id,
    da.airport_name AS destination_airport,
    da.country AS destination_country,

    f.departure_time,
    f.arrival_time,

    f.aircraft_type,
    f.status,

    DATEDIFF(MINUTE, f.departure_time, f.arrival_time) / 60.0
        AS flight_duration_hours,

    CASE
        WHEN f.status = 'Completed' THEN 'Successful'
        WHEN f.status = 'Delayed' THEN 'Operational Issue'
        WHEN f.status = 'Cancelled' THEN 'Operational Issue'
        ELSE 'Other'
    END AS status_category,

    CASE
        WHEN DATEDIFF(MINUTE, f.departure_time, f.arrival_time) < 180
            THEN 'Short Haul'
        WHEN DATEDIFF(MINUTE, f.departure_time, f.arrival_time) < 360
            THEN 'Medium Haul'
        ELSE 'Long Haul'
    END AS flight_type

FROM processing.mast_flights f
LEFT JOIN processing.mast_airports oa
    ON f.origin_airport_id = oa.airport_id
LEFT JOIN processing.mast_airports da
    ON f.destination_airport_id = da.airport_id;
GO

CREATE OR ALTER VIEW analytics.fact_route_performance
AS
SELECT
    f.origin_airport_id,
    oa.airport_name AS origin_airport,
    oa.country AS origin_country,

    f.destination_airport_id,
    da.airport_name AS destination_airport,
    da.country AS destination_country,

    COUNT(DISTINCT f.flight_id) AS total_flights,

    COUNT(DISTINCT t.ticket_id) AS total_bookings,

    SUM(t.price_usd) AS total_revenue,

    AVG(t.price_usd) AS avg_ticket_price,

    AVG(
        DATEDIFF
        (
            MINUTE,
            f.departure_time,
            f.arrival_time
        )
    ) / 60.0 AS avg_flight_duration_hours,

    CASE
        WHEN oa.country = da.country
            THEN 'Domestic'
        ELSE 'International'
    END AS route_type

FROM processing.mast_flights f

LEFT JOIN processing.serv_tickets t
    ON f.flight_id = t.flight_id

LEFT JOIN processing.mast_airports oa
    ON f.origin_airport_id = oa.airport_id

LEFT JOIN processing.mast_airports da
    ON f.destination_airport_id = da.airport_id

GROUP BY
    f.origin_airport_id,
    oa.airport_name,
    oa.country,
    f.destination_airport_id,
    da.airport_name,
    da.country;
GO
