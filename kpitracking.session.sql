-- KPI 1: Cost Concentration Tracking (baseline establishment)
WITH drug_totals AS (
    SELECT Gnrc_Name, Brnd_Name,
           SUM(Tot_Drug_Cst) as total_cost
    FROM Medicare_PartD
    WHERE Tot_Drug_Cst IS NOT NULL AND Tot_Drug_Cst > 0
        AND Prscrbr_Geo_Lvl = 'National'
    GROUP BY Gnrc_Name, Brnd_Name
),
ranked_drugs AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY total_cost DESC) as cost_rank,
           SUM(total_cost) OVER () as grand_total,
           SUM(total_cost) OVER (ORDER BY total_cost DESC) as running_total
    FROM drug_totals
)
SELECT cost_rank, Gnrc_Name, Brnd_Name, total_cost,
       ROUND(100.0 * total_cost / grand_total, 2) as pct_of_total,
       ROUND(100.0 * running_total / grand_total, 2) as cumulative_pct
FROM ranked_drugs
WHERE cost_rank <= 10
ORDER BY cost_rank
;

-- KPI 2: National & State Generic Substitution Rate

--National Generic Substitution Rate
SELECT 
    SUM(CASE WHEN Gnrc_Name = 'Warfarin Sodium' THEN Tot_Clms ELSE 0 END) * 100.0 / 
        SUM(CASE WHEN Gnrc_Name IN ('Warfarin Sodium', 'Apixaban', 'Rivaroxaban') THEN Tot_Clms ELSE 0 END) as blood_thinner_generic_rate,
    SUM(CASE WHEN Gnrc_Name = 'Adalimumab-Bwwd' THEN Tot_Clms ELSE 0 END) * 100.0 / 
        SUM(CASE WHEN Gnrc_Name IN ('Adalimumab-Bwwd', 'Adalimumab') THEN Tot_Clms ELSE 0 END) as immunosupp_generic_rate,
    SUM(CASE WHEN Gnrc_Name = 'Metformin Hcl' THEN Tot_Clms ELSE 0 END) * 100.0 / 
        SUM(CASE WHEN Gnrc_Name IN ('Metformin Hcl', 'Semaglutide', 'Empagliflozin', 'Dulaglutide') THEN Tot_Clms ELSE 0 END) as diabetes_generic_rate
FROM Medicare_PartD
WHERE Prscrbr_Geo_Lvl = 'National'
;

-- State Territory Generic Substitution Rate
SELECT 
    Prscrbr_Geo_Desc,
    ROUND(SUM(CASE WHEN Gnrc_Name = 'Warfarin Sodium' THEN Tot_Clms ELSE 0 END) * 100.0
        / NULLIF(SUM(CASE WHEN Gnrc_Name IN ('Warfarin Sodium', 'Apixaban', 'Rivaroxaban') 
                    THEN Tot_Clms ELSE 0 END), 0), 2) AS blood_thinner_generic_rate,
    ROUND(SUM(CASE WHEN Gnrc_Name = 'Adalimumab-Bwwd' THEN Tot_Clms ELSE 0 END) * 100.0
        /NULLIF(SUM(CASE WHEN Gnrc_Name IN ('Adalimumab-Bwwd', 'Adalimumab') 
                    THEN Tot_Clms ELSE 0 END), 0), 2) AS immunosupp_generic_rate,
    ROUND(SUM(CASE WHEN Gnrc_Name = 'Metformin Hcl' THEN Tot_Clms ELSE 0 END) * 100.0
        /NULLIF(SUM(CASE WHEN Gnrc_Name IN ('Metformin Hcl', 'Semaglutide', 'Empagliflozin', 'Dulaglutide') 
                    THEN Tot_Clms ELSE 0 END), 0), 2) AS diabetes_generic_rate
FROM Medicare_PartD
WHERE Prscrbr_Geo_Lvl <> 'National'
    AND Prscrbr_Geo_Desc IS NOT NULL
    AND Prscrbr_Geo_Desc <> 'Unknown'
    AND Prscrbr_Geo_Desc <> 'Foreign Country'
GROUP BY Prscrbr_Geo_Desc
ORDER BY blood_thinner_generic_rate ASC
;
