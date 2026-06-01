-- Initial data structure exploration
SELECT COUNT(*) as total_records,
       COUNT(DISTINCT Gnrc_Name) as unique_generic_drugs,
       COUNT(DISTINCT Brnd_Name) as unique_brand_drugs,
       COUNT(DISTINCT Prscrbr_Geo_Desc) as unique_geo
FROM medicare_partd
;

--Total claims
SELECT 
    SUM(Tot_Clms) as national_tot_clms
FROM medicare_partd
WHERE prscrbr_geo_lvl = 'National'
;

-- Data quality check
SELECT COUNT(*) as records_with_null_cost,
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medicare_partd) as null_percentage
FROM medicare_partd 
WHERE Tot_Drug_Cst IS NULL OR Tot_Drug_Cst = 0
;

SELECT COUNT(*) as unknown_geo,
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medicare_partd) as null_percentage
FROM medicare_partd 
WHERE Prscrbr_Geo_Desc IS NULL OR Prscrbr_Geo_Desc = 'Unknown'
;

SELECT COUNT(*) as null_beneficiaries,
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medicare_partd) as null_percentage
FROM medicare_partd 
WHERE Tot_Benes IS NULL OR Tot_Benes = 0
;

-- Initial outlier detection geographic distribution
SELECT Prscrbr_Geo_Desc,
       SUM(Tot_Drug_Cst) as total_cost,
       COUNT(*) as drug_count,
       SUM(Tot_Clms) as total_claims,
       ROUND(100.0 * SUM(Tot_Drug_Cst) / (SELECT SUM(Tot_Drug_Cst) FROM Medicare_PartD), 2) as pct_of_total
FROM medicare_partd
GROUP BY Prscrbr_Geo_Desc
ORDER BY total_cost DESC
;

--National vs combined state totals comparison
WITH national_totals AS (
    SELECT
        Gnrc_Name,
        SUM(Tot_Drug_Cst) AS national_tot_cost
    FROM medicare_partd
    WHERE Prscrbr_Geo_Desc = 'National'
    GROUP BY Gnrc_Name
),

all_state_totals AS (
    SELECT
        Gnrc_Name,
        SUM(Tot_Drug_Cst) AS combined_state_tot_cost
    FROM medicare_partd
    WHERE Prscrbr_Geo_Desc <> 'National'
    GROUP BY Gnrc_Name
)

SELECT
    n.Gnrc_Name,
    n.national_tot_cost,
    s.combined_state_tot_cost,
    CASE
       WHEN n.national_tot_cost = s.combined_state_tot_cost
       THEN 'Equal'
       ELSE 'Not Equal'
       END AS cost_match_status,
    (s.combined_state_tot_cost - n.national_tot_cost) AS cost_difference
FROM national_totals n
JOIN all_state_totals s
    ON n.Gnrc_Name = s.Gnrc_Name
ORDER BY
    cost_difference DESC
;