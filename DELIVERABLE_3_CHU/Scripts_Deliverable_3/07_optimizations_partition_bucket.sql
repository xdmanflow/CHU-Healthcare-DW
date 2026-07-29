-- =============================================================================
-- CHU Deliverable 2 - Script 07: Partitioning and bucketing optimizations
-- Run AFTER initial load (script 05). Creates optimized copies of key tables.
-- =============================================================================

USE chu_dwh;

-- ---------------------------------------------------------------------------
-- 1. FACT_DEATH: ensure partition pruning on year_num (critical for ~25M rows)
-- ---------------------------------------------------------------------------
-- If fact_death was loaded without partitions populated correctly:
-- MSCK REPAIR TABLE fact_death;

-- Optimized death table with ORC + SNAPPY (rebuild from existing fact)
DROP TABLE IF EXISTS fact_death_opt;
CREATE TABLE fact_death_opt (
  death_sk        BIGINT,
  time_sk         INT,
  geo_sk          INT,
  gender          STRING,
  age_at_death    INT,
  age_group       STRING,
  death_count     INT
)
PARTITIONED BY (year_num SMALLINT)
CLUSTERED BY (geo_sk) INTO 32 BUCKETS
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

INSERT OVERWRITE TABLE fact_death_opt PARTITION (year_num)
SELECT death_sk, time_sk, geo_sk, gender, age_at_death, age_group, death_count, year_num
FROM fact_death;

-- Optional swap (uncomment after validation):
-- ALTER TABLE fact_death RENAME TO fact_death_old;
-- ALTER TABLE fact_death_opt RENAME TO fact_death;

-- ---------------------------------------------------------------------------
-- 2. FACT_HOSPITALIZATION: partition by year + bucket by patient_sk for joins
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS fact_hospitalization_opt;
CREATE TABLE fact_hospitalization_opt (
  hospitalization_sk    BIGINT,
  time_sk               INT,
  patient_sk            INT,
  hospital_sk           INT,
  diagnosis_sk          INT,
  hospitalization_count INT,
  duration_days         INT
)
PARTITIONED BY (year_num SMALLINT)
CLUSTERED BY (patient_sk) INTO 16 BUCKETS
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

INSERT OVERWRITE TABLE fact_hospitalization_opt PARTITION (year_num)
SELECT hospitalization_sk, time_sk, patient_sk, hospital_sk, diagnosis_sk,
       hospitalization_count, duration_days, year_num
FROM fact_hospitalization;

-- ---------------------------------------------------------------------------
-- 3. DIM_PATIENT: bucket by patient_id for join with facts
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_patient_opt;
CREATE TABLE dim_patient_opt (
  patient_sk   INT,
  patient_id   BIGINT,
  gender       STRING,
  age          INT,
  age_group    STRING
)
CLUSTERED BY (patient_id) INTO 16 BUCKETS
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

INSERT OVERWRITE TABLE dim_patient_opt
SELECT patient_sk, patient_id, gender, age, age_group FROM dim_patient;

-- ---------------------------------------------------------------------------
-- 4. STAGING DEATH: partition external table by death year (load pattern)
-- ---------------------------------------------------------------------------
USE chu_staging;

-- Example: add partition after loading 2019 slice to HDFS
-- ALTER TABLE stg_deces ADD IF NOT EXISTS PARTITION (annee_deces=2019)
--   LOCATION '/user/chu/data/staging/deces/year=2019';
-- MSCK REPAIR TABLE stg_deces;

-- ---------------------------------------------------------------------------
-- 5. Hive settings for benchmark runs (session-level)
-- ---------------------------------------------------------------------------
-- SET hive.exec.dynamic.partition=true;
-- SET hive.exec.dynamic.partition.mode=nonstrict;
-- SET hive.optimize.ppd=true;
-- SET hive.vectorized.execution.enabled=true;
-- SET hive.cbo.enable=true;

-- ---------------------------------------------------------------------------
-- 6. Verify partition metadata
-- ---------------------------------------------------------------------------
USE chu_dwh;
SHOW PARTITIONS fact_death;
SHOW PARTITIONS fact_hospitalization;
SHOW PARTITIONS fact_consultation;
SHOW PARTITIONS fact_satisfaction;
