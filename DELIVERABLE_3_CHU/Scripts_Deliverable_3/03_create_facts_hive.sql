-- =============================================================================
-- CHU Data Warehouse - Deliverable 1
-- Script 03: Fact tables (4 analysis areas)
-- =============================================================================

USE chu_dwh;

-- FACT_CONSULTATION
DROP TABLE IF EXISTS fact_consultation;
CREATE TABLE fact_consultation (
  consultation_sk       BIGINT,
  time_sk                 INT,
  patient_sk              INT,
  hospital_sk             INT,
  diagnosis_sk            INT,
  professional_sk         INT,
  consultation_count      INT,
  consultation_cost       DECIMAL(12,2)
)
PARTITIONED BY (year_num SMALLINT)
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- FACT_HOSPITALIZATION
DROP TABLE IF EXISTS fact_hospitalization;
CREATE TABLE fact_hospitalization (
  hospitalization_sk      BIGINT,
  time_sk                 INT,
  patient_sk              INT,
  hospital_sk             INT,
  diagnosis_sk            INT,
  hospitalization_count   INT,
  duration_days           INT
)
PARTITIONED BY (year_num SMALLINT)
STORED AS ORC;

-- FACT_DEATH
DROP TABLE IF EXISTS fact_death;
CREATE TABLE fact_death (
  death_sk          BIGINT,
  time_sk           INT,
  geo_sk            INT,
  gender            STRING,
  age_at_death      INT,
  age_group         STRING,
  death_count       INT
)
PARTITIONED BY (year_num SMALLINT)
STORED AS ORC;

-- FACT_SATISFACTION
DROP TABLE IF EXISTS fact_satisfaction;
CREATE TABLE fact_satisfaction (
  satisfaction_sk       BIGINT,
  time_sk                 INT,
  hospital_sk           INT,
  region                STRING,
  satisfaction_score    DOUBLE,
  satisfaction_count    BIGINT,
  recommendation_rate   DOUBLE,
  campagne_annee        INT
)
PARTITIONED BY (campagne_annee INT)
STORED AS ORC;
