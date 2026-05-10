# Data Warehouse and Analytics Project
Welcome to the Data Warehouse and Analytics Project repository! 
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights

# Data Architecture

  The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers:
<img width="1544" height="803" alt="data_architecture3 png" src="https://github.com/user-attachments/assets/8b02547d-2983-4df6-9402-d65c1789599f" />




  
* Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
* Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
* Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.

# Project Overview
This project involves:

* Data Architecture: Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
* ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.
* Data Modeling: Developing fact and dimension tables optimized for analytical queries.
* Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.
🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:

SQL Development
Data Architect
Data Engineering
ETL Pipeline Developer
Data Modeling
Data Analytics
# Project Requirements
Building the Data Warehouse 
Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

Specifications
* Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
* Data Quality: Cleanse and resolve data quality issues prior to analysis.
* Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
* Scope: Focus on the latest dataset only; historization of data is not required.
* Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.
# BI: Analytics & Reporting (Data Analysis)
Objective
Develop SQL-based analytics to deliver detailed insights into:

Customer Behavior
Product Performance
Sales Trends
These insights empower stakeholders with key business metrics, enabling strategic decision-making.
# Repository Structure

```bash
data-warehouse-project/
│
├── datasets/                          # Raw datasets (ERP and CRM data)
│
├── docs/                              # Project documentation & architecture
│   ├── etl.drawio                     # ETL process diagrams
│   ├── data_architecture.drawio       # Overall system architecture
│   ├── data_catalog.md                # Dataset metadata & field descriptions
│   ├── data_flow.drawio               # Data flow diagram
│   ├── data_models.drawio             # Star schema / data models
│   ├── naming-conventions.md          # Naming standards for tables & columns
│
├── scripts/                           # SQL scripts for ETL process
│   ├── bronze/                        # Raw data ingestion scripts
│   ├── silver/                        # Data cleaning & transformation scripts
│   ├── gold/                          # Analytical model / reporting layer
│
├── tests/                             # Data validation & quality checks
│
├── README.md                          # Project overview & instructions
├── LICENSE                            # License information
├── .gitignore                         # Files to ignore in Git
└── requirements.txt                   # Project dependencies
```


# License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.

