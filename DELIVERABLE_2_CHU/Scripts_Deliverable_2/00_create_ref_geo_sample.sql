-- Simplified geo reference (sample) - complete with official INSEE data
-- Enables deces.code_lieu_deces -> region join for requirement B7

USE chu_staging;

INSERT OVERWRITE TABLE stg_ref_geo
SELECT code_commune, nom_commune, code_departement, nom_region
FROM (
  SELECT '02691' AS code_commune, 'Saint-Quentin' AS nom_commune, '02' AS code_departement, 'Hauts-de-France' AS nom_region
  UNION ALL SELECT '75101', 'Paris 1er', '75', 'Ile-de-France'
  UNION ALL SELECT '13055', 'Marseille', '13', 'Provence-Alpes-Cote d Azur'
  -- TODO: load full communes-france.csv
) ref;

USE chu_dwh;
INSERT OVERWRITE TABLE dim_geo
SELECT
  ROW_NUMBER() OVER (ORDER BY code_commune) AS geo_sk,
  code_commune,
  nom_commune AS commune_label,
  code_departement,
  nom_region AS region
FROM chu_staging.stg_ref_geo;
