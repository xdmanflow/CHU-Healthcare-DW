-- =============================================================================
-- CHU - Script 05: Load DWH (dimensions then facts)
-- =============================================================================

USE chu_dwh;

-- ----- DIM_TIME (calendar 2015-2021) -----
INSERT OVERWRITE TABLE dim_time
SELECT
  CAST(DATE_FORMAT(d, 'yyyyMMdd') AS INT) AS time_sk,
  d AS full_date,
  DAY(d) AS day_of_month,
  MONTH(d) AS month_num,
  QUARTER(d) AS quarter_num,
  YEAR(d) AS year_num,
  DATE_FORMAT(d, 'MMMM') AS month_name,
  CASE WHEN DAYOFWEEK(d) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM (
  SELECT DATE_ADD('2015-01-01', pos) AS d
  FROM (
    SELECT posexplode(split(space(2556), '')) AS (pos, val)
  ) t
) cal
WHERE d <= '2021-12-31';

-- ----- DIM_HOSPITAL -----
INSERT OVERWRITE TABLE dim_hospital
SELECT
  ROW_NUMBER() OVER (ORDER BY e.identifiant_organisation) AS hospital_sk,
  e.identifiant_organisation,
  e.finess_site,
  e.raison_sociale_site,
  e.commune,
  e.code_commune,
  e.code_postal,
  COALESCE(s.region, 'UNKNOWN') AS region
FROM chu_staging.stg_etablissement e
LEFT JOIN (
  SELECT DISTINCT finess_geo, region
  FROM chu_staging.stg_satisfaction_clean
) s ON e.finess_site = s.finess_geo;

-- ----- DIM_PATIENT -----
INSERT OVERWRITE TABLE dim_patient
SELECT
  ROW_NUMBER() OVER (ORDER BY p.id_patient) AS patient_sk,
  p.id_patient AS patient_id,
  p.sexe AS gender,
  p.age,
  CASE
    WHEN p.age < 18 THEN '0-17'
    WHEN p.age < 65 THEN '18-64'
    ELSE '65+'
  END AS age_group
FROM chu_staging.stg_patient p;

-- ----- DIM_DIAGNOSIS (depuis hospitalisations + consultations) -----
INSERT OVERWRITE TABLE dim_diagnosis
SELECT
  ROW_NUMBER() OVER (ORDER BY code_diag) AS diagnosis_sk,
  code_diag,
  MAX(libelle) AS diagnosis_label,
  SUBSTR(code_diag, 1, 1) AS category
FROM (
  SELECT code_diagnostic AS code_diag, libelle_diagnostic AS libelle
  FROM chu_staging.stg_hospitalisation_clean
  UNION ALL
  SELECT code_diag, code_diag AS libelle FROM chu_staging.stg_consultation_enriched
) u
GROUP BY code_diag;

-- ----- DIM_PROFESSIONAL -----
INSERT OVERWRITE TABLE dim_professional
SELECT
  ROW_NUMBER() OVER (ORDER BY identifiant) AS professional_sk,
  identifiant AS professional_id,
  nom AS last_name,
  prenom AS first_name,
  profession,
  specialite AS specialty
FROM chu_staging.stg_professionnel;

-- ----- FACT_HOSPITALIZATION -----
INSERT OVERWRITE TABLE fact_hospitalization PARTITION (year_num)
SELECT
  h.num_hospitalisation AS hospitalization_sk,
  CAST(DATE_FORMAT(h.date_entree, 'yyyyMMdd') AS INT) AS time_sk,
  dp.patient_sk,
  dh.hospital_sk,
  dd.diagnosis_sk,
  1 AS hospitalization_count,
  h.duree_jours AS duration_days,
  YEAR(h.date_entree) AS year_num
FROM chu_staging.stg_hospitalisation_clean h
JOIN dim_patient dp ON h.id_patient = dp.patient_id
JOIN dim_hospital dh ON h.identifiant_organisation = dh.identifiant_organisation
JOIN dim_diagnosis dd ON h.code_diagnostic = dd.code_diag;

-- ----- FACT_CONSULTATION -----
INSERT OVERWRITE TABLE fact_consultation PARTITION (year_num)
SELECT
  c.num_consultation AS consultation_sk,
  CAST(DATE_FORMAT(c.date_consultation, 'yyyyMMdd') AS INT) AS time_sk,
  dp.patient_sk,
  dh.hospital_sk,
  dd.diagnosis_sk,
  dpr.professional_sk,
  1 AS consultation_count,
  CAST(NULL AS DECIMAL(12,2)) AS consultation_cost,
  YEAR(c.date_consultation) AS year_num
FROM chu_staging.stg_consultation_enriched c
JOIN dim_patient dp ON c.id_patient = dp.patient_id
LEFT JOIN dim_hospital dh ON c.identifiant_organisation = dh.identifiant_organisation
LEFT JOIN dim_diagnosis dd ON c.code_diag = dd.code_diag
LEFT JOIN dim_professional dpr ON c.id_prof_sante = dpr.professional_id;

-- ----- FACT_DEATH (2019) -----
INSERT OVERWRITE TABLE fact_death PARTITION (year_num)
SELECT
  ROW_NUMBER() OVER (ORDER BY d.date_deces, d.code_lieu_deces) AS death_sk,
  CAST(DATE_FORMAT(d.date_deces, 'yyyyMMdd') AS INT) AS time_sk,
  dg.geo_sk,
  CASE WHEN d.sexe = 1 THEN 'M' WHEN d.sexe = 2 THEN 'F' ELSE 'U' END AS gender,
  YEAR(d.date_deces) - YEAR(d.date_naissance) AS age_at_death,
  CASE
    WHEN YEAR(d.date_deces) - YEAR(d.date_naissance) < 18 THEN '0-17'
    WHEN YEAR(d.date_deces) - YEAR(d.date_naissance) < 65 THEN '18-64'
    ELSE '65+'
  END AS age_group,
  1 AS death_count,
  2019 AS year_num
FROM chu_staging.stg_deces d
JOIN dim_geo dg ON d.code_lieu_deces = dg.code_commune
WHERE YEAR(d.date_deces) = 2019;

-- ----- FACT_SATISFACTION -----
INSERT OVERWRITE TABLE fact_satisfaction PARTITION (campagne_annee)
SELECT
  ROW_NUMBER() OVER (ORDER BY s.finess) AS satisfaction_sk,
  CAST(CONCAT(s.campagne_annee, '0101') AS INT) AS time_sk,
  dh.hospital_sk,
  s.region,
  s.score_all_rea_ajust AS satisfaction_score,
  s.nb_rep_score_all_rea_ajust AS satisfaction_count,
  s.taux_reco_brut AS recommendation_rate,
  s.campagne_annee
FROM chu_staging.stg_satisfaction_clean s
LEFT JOIN dim_hospital dh ON s.finess = dh.finess_site;
