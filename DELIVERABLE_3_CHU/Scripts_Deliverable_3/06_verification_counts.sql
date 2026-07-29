-- =============================================================================
-- CHU - Script 06: Load verification (row counts)
-- =============================================================================

USE chu_staging;
SELECT 'stg_hospitalisation' AS table_name, COUNT(*) AS nb_lignes FROM stg_hospitalisation
UNION ALL SELECT 'stg_etablissement', COUNT(*) FROM stg_etablissement
UNION ALL SELECT 'stg_professionnel', COUNT(*) FROM stg_professionnel
UNION ALL SELECT 'stg_satisfaction_clean', COUNT(*) FROM stg_satisfaction_clean;

USE chu_dwh;
SELECT 'dim_time' AS table_name, COUNT(*) AS nb_lignes FROM dim_time
UNION ALL SELECT 'dim_patient', COUNT(*) FROM dim_patient
UNION ALL SELECT 'dim_hospital', COUNT(*) FROM dim_hospital
UNION ALL SELECT 'dim_diagnosis', COUNT(*) FROM dim_diagnosis
UNION ALL SELECT 'dim_professional', COUNT(*) FROM dim_professional
UNION ALL SELECT 'dim_geo', COUNT(*) FROM dim_geo;

SELECT 'fact_consultation' AS table_name, COUNT(*) AS nb_lignes FROM fact_consultation
UNION ALL SELECT 'fact_hospitalization', COUNT(*) FROM fact_hospitalization
UNION ALL SELECT 'fact_death', COUNT(*) FROM fact_death
UNION ALL SELECT 'fact_satisfaction', COUNT(*) FROM fact_satisfaction;

-- Business control queries (deliverable 1 examples)
-- B3: overall hospitalizations
SELECT SUM(hospitalization_count) AS total_hospitalisations FROM fact_hospitalization;

-- B7: deaths by region 2019
SELECT g.region, SUM(f.death_count) AS death_total
FROM fact_death f
JOIN dim_geo g ON f.geo_sk = g.geo_sk
WHERE f.year_num = 2019
GROUP BY g.region
ORDER BY death_total DESC
LIMIT 20;

-- B8: average satisfaction by region (2020 campaign)
SELECT region, AVG(satisfaction_score) AS avg_score, SUM(satisfaction_count) AS response_count
FROM fact_satisfaction
WHERE campagne_annee = 2020
GROUP BY region
ORDER BY avg_score DESC;
