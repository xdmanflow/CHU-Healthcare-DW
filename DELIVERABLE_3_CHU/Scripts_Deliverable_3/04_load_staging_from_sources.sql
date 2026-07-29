-- =============================================================================
-- CHU - Script 04: STAGING load examples (post-Talend or LOAD DATA)
-- Adjust HDFS paths for your cluster
-- =============================================================================

USE chu_staging;

-- Example: copy hospitalization file to HDFS then refresh
-- hdfs dfs -put "Hospitalisations.csv" /user/chu/data/staging/hospitalisation/
-- MSCK REPAIR TABLE stg_hospitalisation;

-- Hospitalization date transformation (intermediate table)
DROP TABLE IF EXISTS stg_hospitalisation_clean;
CREATE TABLE stg_hospitalisation_clean
STORED AS ORC
AS
SELECT
  num_hospitalisation,
  id_patient,
  identifiant_organisation,
  code_diagnostic,
  libelle_diagnostic,
  CAST(
    CONCAT(
      SUBSTR(date_entree_raw, 7, 4), '-',
      SUBSTR(date_entree_raw, 4, 2), '-',
      SUBSTR(date_entree_raw, 1, 2)
    ) AS DATE
  ) AS date_entree,
  duree_jours
FROM stg_hospitalisation
WHERE identifiant_organisation IS NOT NULL
  AND id_patient IS NOT NULL;

-- Enrich consultations with facility via professional activity
DROP TABLE IF EXISTS stg_consultation_enriched;
CREATE TABLE stg_consultation_enriched
STORED AS ORC
AS
SELECT
  c.num_consultation,
  c.id_patient,
  c.id_prof_sante,
  c.code_diag,
  c.motif,
  c.date_consultation,
  a.identifiant_organisation
FROM stg_consultation c
LEFT JOIN stg_activite_professionnel a
  ON c.id_prof_sante = a.identifiant
WHERE a.mode_exercice = 'Salarie' OR a.identifiant_organisation IS NOT NULL;

-- Deaths: load 2019 partition only (requirement B7)
-- ALTER TABLE stg_deces ADD IF NOT EXISTS PARTITION (annee_deces=2019)
--   LOCATION '/user/chu/data/staging/deces/annee=2019';

-- Satisfaction: normalize score (comma decimal format)
DROP TABLE IF EXISTS stg_satisfaction_clean;
CREATE TABLE stg_satisfaction_clean
STORED AS ORC
AS
SELECT
  finess,
  region,
  CAST(REGEXP_REPLACE(CAST(score_all_rea_ajust AS STRING), ',', '.') AS DOUBLE) AS score_all_rea_ajust,
  nb_rep_score_all_rea_ajust,
  CAST(REGEXP_REPLACE(CAST(taux_reco_brut AS STRING), ',', '.') AS DOUBLE) AS taux_reco_brut,
  2020 AS campagne_annee
FROM stg_satisfaction_esatis
WHERE region IS NOT NULL
  AND score_all_rea_ajust IS NOT NULL;
