-- =============================================================================
-- CHU Data Warehouse - Deliverable 1
-- Script 02: Conformed dimensions (Hive / ORC)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS chu_dwh
  COMMENT 'CHU decision-support data warehouse'
  LOCATION '/user/hive/warehouse/chu_dwh.db';

USE chu_dwh;

-- DIM_TIME
DROP TABLE IF EXISTS dim_time;
CREATE TABLE dim_time (
  time_sk       INT,
  full_date     DATE,
  day_of_month  TINYINT,
  month_num     TINYINT,
  quarter_num   TINYINT,
  year_num      SMALLINT,
  month_name    STRING,
  is_weekend    BOOLEAN
)
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- DIM_PATIENT
DROP TABLE IF EXISTS dim_patient;
CREATE TABLE dim_patient (
  patient_sk    INT,
  patient_id    BIGINT,
  gender        STRING,
  age           INT,
  age_group     STRING
)
STORED AS ORC;

-- DIM_HOSPITAL
DROP TABLE IF EXISTS dim_hospital;
CREATE TABLE dim_hospital (
  hospital_sk               INT,
  identifiant_organisation  STRING,
  finess_site               STRING,
  hospital_name             STRING,
  commune                   STRING,
  code_commune              STRING,
  code_postal               STRING,
  region                    STRING
)
STORED AS ORC;

-- DIM_DIAGNOSIS
DROP TABLE IF EXISTS dim_diagnosis;
CREATE TABLE dim_diagnosis (
  diagnosis_sk      INT,
  code_diag         STRING,
  diagnosis_label   STRING,
  category          STRING
)
STORED AS ORC;

-- DIM_PROFESSIONAL
DROP TABLE IF EXISTS dim_professional;
CREATE TABLE dim_professional (
  professional_sk   INT,
  professional_id   STRING,
  last_name         STRING,
  first_name        STRING,
  profession        STRING,
  specialty         STRING
)
STORED AS ORC;

-- DIM_GEO (deces)
DROP TABLE IF EXISTS dim_geo;
CREATE TABLE dim_geo (
  geo_sk            INT,
  code_commune      STRING,
  commune_label     STRING,
  code_departement  STRING,
  region            STRING
)
STORED AS ORC;
