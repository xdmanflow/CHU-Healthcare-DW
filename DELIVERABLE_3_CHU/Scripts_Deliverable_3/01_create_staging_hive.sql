-- =============================================================================
-- CHU Data Warehouse - Deliverable 1
-- Script 01: Create STAGING schema (Hive)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS chu_staging
  COMMENT 'Staging zone - cleansed raw CHU data'
  LOCATION '/user/hive/warehouse/chu_staging.db';

USE chu_staging;

-- -----------------------------------------------------------------------------
-- Hospitalisations (DATA 2024)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_hospitalisation;
CREATE EXTERNAL TABLE stg_hospitalisation (
  num_hospitalisation     BIGINT,
  id_patient              BIGINT,
  identifiant_organisation STRING,
  code_diagnostic         STRING,
  libelle_diagnostic      STRING,
  date_entree_raw         STRING,
  date_entree             DATE,
  duree_jours             INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION '/user/chu/data/staging/hospitalisation'
TBLPROPERTIES ('skip.header.line.count'='1');

-- -----------------------------------------------------------------------------
-- Healthcare facilities
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_etablissement;
CREATE EXTERNAL TABLE stg_etablissement (
  identifiant_organisation      STRING,
  finess_site                   STRING,
  finess_etablissement_juridique STRING,
  raison_sociale_site           STRING,
  commune                       STRING,
  code_commune                  STRING,
  code_postal                   STRING,
  pays                          STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION '/user/chu/data/staging/etablissement'
TBLPROPERTIES ('skip.header.line.count'='1');

-- -----------------------------------------------------------------------------
-- Professionnels et activite
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_professionnel;
CREATE EXTERNAL TABLE stg_professionnel (
  identifiant              STRING,
  civilite                 STRING,
  categorie_professionnelle STRING,
  nom                      STRING,
  prenom                   STRING,
  profession               STRING,
  specialite               STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION '/user/chu/data/staging/professionnel'
TBLPROPERTIES ('skip.header.line.count'='1');

DROP TABLE IF EXISTS stg_activite_professionnel;
CREATE EXTERNAL TABLE stg_activite_professionnel (
  identifiant              STRING,
  identifiant_organisation STRING,
  mode_exercice            STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION '/user/chu/data/staging/activite_professionnel'
TBLPROPERTIES ('skip.header.line.count'='1');

-- -----------------------------------------------------------------------------
-- Consultations (export PostgreSQL ou fichier intermediaire Talend)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_consultation;
CREATE TABLE stg_consultation (
  num_consultation   BIGINT,
  id_patient         BIGINT,
  id_prof_sante      STRING,
  code_diag          STRING,
  motif              STRING,
  date_consultation  DATE,
  heure_debut        STRING,
  heure_fin          STRING,
  identifiant_organisation STRING  -- enriched via professional activity join
)
STORED AS ORC;

-- -----------------------------------------------------------------------------
-- Patients (export PostgreSQL)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_patient;
CREATE TABLE stg_patient (
  id_patient   BIGINT,
  sexe         STRING,
  age          INT,
  date_naissance DATE
)
STORED AS ORC;

-- -----------------------------------------------------------------------------
-- Deaths (large file - use partitioned load)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_deces;
CREATE EXTERNAL TABLE stg_deces (
  nom                STRING,
  prenom             STRING,
  sexe               TINYINT,
  date_naissance     DATE,
  code_lieu_naissance STRING,
  lieu_naissance     STRING,
  date_deces         DATE,
  code_lieu_deces    STRING,
  numero_acte_deces  STRING
)
PARTITIONED BY (annee_deces INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC
LOCATION '/user/chu/data/staging/deces';

-- -----------------------------------------------------------------------------
-- Satisfaction ESATIS 48h MCO 2020 (B8 requirement)
-- Source: Satisfaction/2020/resultats-esatis48h-mco-open-data-2020.xlsx
-- Convert xlsx to CSV first: python IMPLEMENTATION/export_satisfaction_2020_to_csv.py
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_satisfaction_esatis;
CREATE EXTERNAL TABLE stg_satisfaction_esatis (
  finess                    STRING,
  rs_finess                 STRING,
  finess_geo                STRING,
  region                    STRING,
  score_all_rea_ajust       DOUBLE,
  nb_rep_score_all_rea_ajust BIGINT,
  taux_reco_brut            DOUBLE,
  campagne_annee            INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION '/user/chu/data/staging/satisfaction/esatis_2020'
TBLPROPERTIES ('skip.header.line.count'='1');

-- -----------------------------------------------------------------------------
-- Geo reference (municipality -> region) - to be loaded
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg_ref_geo;
CREATE TABLE stg_ref_geo (
  code_commune   STRING,
  nom_commune    STRING,
  code_departement STRING,
  nom_region     STRING
)
STORED AS ORC;
