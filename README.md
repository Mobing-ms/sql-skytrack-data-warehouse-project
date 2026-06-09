# ✈️ SkyTrack Data Warehouse

A modern Data Engineering project that implements a layered Data Warehouse architecture using airline data. The project demonstrates the complete data lifecycle, from raw data ingestion to business-ready analytics.

## 🏗️ Architecture

### 🥉 Acquisition Layer

Stores raw data from source systems without modifications.

### 🥈 Processing Layer

Performs data cleansing, standardization, validation, enrichment, and transformation.

### 🥇 Analytics Layer

Integrates processed data into fact and dimension tables, applies business rules, and supports reporting and analytics.

## 📂 Source Data

### Master Data

* Airports
* Employees

### Operational Data

* Flights
* Passengers
* Tickets

## 🔄 Data Flow

```text
Source Systems
      ↓
Acquisition Layer
      ↓
Processing Layer
      ↓
Analytics Layer
      ↓
Power BI / SQL Analytics / ML
```

## 🎯 Key Features

* ETL Pipeline Design
* Data Quality Management
* Data Transformation
* Dimensional Modeling
* Star Schema Architecture
* Business Intelligence Ready


## 📜 License

This project is licensed under the MIT License.


## 👨‍💻 Author

**Akshay M Nair**
