# CHU Healthcare Data Warehouse — Big Data Decision Support System for the French Healthcare World

> A Big Data / Business Intelligence project building a scalable data warehouse for the **Cloud Healthcare Unit (CHU)** group, enabling patient monitoring, mortality tracking, and satisfaction analysis at a national scale.

## Overview

Healthcare facilities generate massive volumes of heterogeneous data — patient records, hospitalization logs, satisfaction surveys, and national death registries — spread across incompatible systems (PostgreSQL databases, CSV exports, flat files). This project designs and implements an end-to-end **Big Data decision-making architecture** that integrates these distributed sources into a single, secure, and query-efficient data warehouse, enabling practitioners and administrators to extract actionable insights for better clinical and operational decisions.

The project follows the full BI/Big Data lifecycle: architecture design → conceptual modeling → physical implementation & optimization → data restitution and storytelling through dashboards.

## Objectives

- Integrate distributed, heterogeneous medical data sources into a unified, persistent data warehouse
- Model the key analytical subject areas (consultations, hospitalizations, deaths, satisfaction) as star/snowflake schemas
- Build and automate ETL jobs to feed the decision-making schema
- Implement, populate, partition, and optimize the physical data model
- Evaluate performance through query response-time benchmarking
- Deliver a dashboard and narrative (storytelling) to support decision-makers

## Data Sources

| Source | Format | Description |
|---|---|---|
| Hospital management system | PostgreSQL | Patients' medical and administrative care records |
| French hospital management data | CSV | National hospital management export |
| Satisfaction surveys | Flat files | Patient satisfaction ratings per facility |
| Death registry | Flat files | National death registry (France) |

## Key Analytical Requirements

- Consultation rate by facility / by diagnosis over a given period
- Overall and diagnosis-based hospitalization rates over a given period
- Hospitalization rates by gender and age
- Consultation rate per healthcare professional
- Number of deaths by region (2019)
- Overall satisfaction rate by region (2020)

## Project Phases

1. **Architecture study** — evaluating and selecting the Big Data / DW architecture
2. **Conceptual data modeling** — dimensional modeling of analysis areas and measures
3. **Physical implementation** — ETL jobs, table creation, loading, partitioning/bucketing
4. **Operation & optimization** — performance measurement and tuning

## Repository Structure

```
.
├── BIG_DATA_PROJECT/        # Core project workspace
├── DATA 2024/                # Raw and source datasets
├── IMPLEMENTATION/           # Physical implementation scripts (DDL, ETL, loading)
├── JETEmitters/               # Talend / JET custom emitter components
├── LIVRABLE_1_CHU/           # Deliverable 1 — Data repository & conceptual model
├── LIVRABLE_2_CHU/           # Deliverable 2 — Physical model & performance optimization
├── LIVRABLE_3_CHU/           # Deliverable 3 — Dashboard, results & storytelling
├── build_docx_reports.py    # Script to auto-generate Word deliverable reports
└── TOS_BD-win-x86_64.exe    # Talend Open Studio for Big Data (ETL tool)
```

## Deliverables

### 📁 Deliverable 1 — Data Repository
Conceptual model of the data and ETL jobs feeding the decision-making schema: modeling of analysis areas/measures, job development, and data warehouse architecture description.
*(Format: Report)*

### 📁 Deliverable 2 — Physical Model & Optimization
Physical implementation and performance assessment: table creation/loading scripts, data verification, population scripts, partitioning/bucketing, and query response-time benchmarks.
*(Format: Report + zipped jobs)*

### 📁 Deliverable 3 — Presentation & Storytelling
Dashboard-driven narrative interpreting the analysis results to inform CHU decision-makers and practitioners, covering methodology, requirements, DW design, and a technical demo.
*(Format: 20-min oral presentation + Q&A)*

## Tech Stack

- **ETL / Integration:** Talend Open Studio for Big Data (TOS_BD)
- **Database:** PostgreSQL
- **Data formats:** CSV, flat files
- **Modeling:** Dimensional (star/snowflake) data warehouse schema
- **Reporting:** Python (`build_docx_reports.py`) for automated Word report generation

## Non-Functional Requirements

The architecture was designed to satisfy:
- **Security** — protection of sensitive medical data
- **Scalability** — handling growing volumes and variety of data
- **Elasticity** — adapting to fluctuating workloads
- **Cost-effectiveness** — efficient use of infrastructure resources

## Team

Group project (3–4 students) — collaborative work across architecture, modeling, ETL development, and reporting phases.

## License

This project was developed as part of an academic Big Data / Business Intelligence course.
