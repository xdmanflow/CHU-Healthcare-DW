-- =============================================================================
-- CHU Deliverable 2 - Script 08: Benchmark query set (before/after optimization)
-- Measure elapsed time in Hive CLI or Beeline. Record in perf/results_*.csv
-- =============================================================================

USE chu_dwh;

-- Q1 - B3: Total hospitalizations (simple aggregation)
-- Expected: fast; baseline fact scan
SELECT SUM(hospitalization_count) AS total_hospitalizations
FROM fact_hospitalization;

-- Q2 - B3: Hospitalizations by year (partition pruning test)
SELECT year_num, SUM(hospitalization_count) AS stays
FROM fact_hospitalization
GROUP BY year_num
ORDER BY year_num;

-- Q3 - B4: Hospitalizations by diagnosis (join + group by)
SELECT d.code_diag, d.diagnosis_label, SUM(f.hospitalization_count) AS stays
FROM fact_hospitalization f
JOIN dim_diagnosis d ON f.diagnosis_sk = d.diagnosis_sk
GROUP BY d.code_diag, d.diagnosis_label
ORDER BY stays DESC
LIMIT 20;

-- Q4 - B5: Hospitalizations by gender and age group (multi-dimension join)
SELECT p.gender, p.age_group, SUM(f.hospitalization_count) AS stays
FROM fact_hospitalization f
JOIN dim_patient p ON f.patient_sk = p.patient_sk
GROUP BY p.gender, p.age_group
ORDER BY stays DESC;

-- Q5 - B1: Consultations by hospital and year
SELECT h.hospital_name, f.year_num, SUM(f.consultation_count) AS consultations
FROM fact_consultation f
JOIN dim_hospital h ON f.hospital_sk = h.hospital_sk
GROUP BY h.hospital_name, f.year_num
ORDER BY consultations DESC
LIMIT 25;

-- Q6 - B2: Consultations by diagnosis code
SELECT d.code_diag, SUM(f.consultation_count) AS consultations
FROM fact_consultation f
JOIN dim_diagnosis d ON f.diagnosis_sk = d.diagnosis_sk
WHERE f.year_num = 2019
GROUP BY d.code_diag
ORDER BY consultations DESC
LIMIT 25;

-- Q7 - B6: Consultations by professional
SELECT pr.last_name, pr.first_name, pr.profession, SUM(f.consultation_count) AS consultations
FROM fact_consultation f
JOIN dim_professional pr ON f.professional_sk = pr.professional_sk
GROUP BY pr.last_name, pr.first_name, pr.profession
ORDER BY consultations DESC
LIMIT 25;

-- Q8 - B7: Deaths by region in 2019 (heavy query - partition + geo join)
SELECT g.region, SUM(f.death_count) AS deaths
FROM fact_death f
JOIN dim_geo g ON f.geo_sk = g.geo_sk
WHERE f.year_num = 2019
GROUP BY g.region
ORDER BY deaths DESC;

-- Q9 - B8: Average satisfaction by region (2020 campaign)
SELECT region,
       AVG(satisfaction_score) AS avg_score,
       SUM(satisfaction_count) AS responses
FROM fact_satisfaction
WHERE campagne_annee = 2020
GROUP BY region
ORDER BY avg_score DESC;

-- Q10 - Full scan stress test on deaths WITHOUT year filter (before optimization baseline)
SELECT gender, SUM(death_count) AS deaths
FROM fact_death
GROUP BY gender;

-- Q11 - Same as Q10 WITH year filter (after optimization should be much faster)
SELECT gender, SUM(death_count) AS deaths
FROM fact_death
WHERE year_num = 2019
GROUP BY gender;

-- Optional: inspect execution plan
-- EXPLAIN SELECT g.region, SUM(f.death_count) FROM fact_death f JOIN dim_geo g ON f.geo_sk = g.geo_sk WHERE f.year_num = 2019 GROUP BY g.region;
