-- Cost concentration analysis (25.8% discovery)
WITH drug_totals AS (
    SELECT Gnrc_Name, Brnd_Name,
           SUM(Tot_Drug_Cst) as total_cost,
           SUM(Tot_Clms) as total_claims
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

SELECT cost_rank, Gnrc_Name, Brnd_Name, total_cost, total_claims,
       ROUND(100.0 * total_cost / grand_total, 2) as pct_of_total,
       ROUND(100.0 * running_total / grand_total, 2) as cumulative_pct
FROM ranked_drugs
WHERE cost_rank <= 50
ORDER BY cost_rank
;

-- Price differential analysis (Blood thinners) (70x discovery)
SELECT Gnrc_Name, Brnd_Name,
       SUM(Tot_Drug_Cst) as total_cost,
       SUM(Tot_Clms) as total_claims,
       ROUND(SUM(Tot_Drug_Cst) / SUM(Tot_Clms), 2) as avg_cost_per_claim
FROM Medicare_PartD
WHERE Gnrc_Name IN ('Apixaban', 'Warfarin Sodium')
  AND Tot_Drug_Cst IS NOT NULL AND Tot_Drug_Cst > 0
  AND Prscrbr_Geo_Lvl = 'National'
GROUP BY Gnrc_Name, Brnd_Name
ORDER BY avg_cost_per_claim DESC
;

--Price differential analysis (Diabetes medication) (128x discovery)
SELECT Gnrc_Name, Brnd_Name,
       SUM(Tot_Drug_Cst) as total_cost,
       SUM(Tot_Clms) as total_claims,
       ROUND(SUM(Tot_Drug_Cst) / SUM(Tot_Clms), 2) as avg_cost_per_claim
FROM Medicare_PartD
WHERE Gnrc_Name IN ('Semaglutide', 'Empagliflozin', 'Dulaglutide','Metformin Hcl')
  AND Tot_Drug_Cst IS NOT NULL AND Tot_Drug_Cst > 0
  AND Prscrbr_Geo_Lvl = 'National'
GROUP BY Gnrc_Name, Brnd_Name
ORDER BY avg_cost_per_claim DESC
;

--Price differential analysis (Biologic immunosuppressants) (7x discovery)
SELECT Gnrc_Name, Brnd_Name,
       SUM(Tot_Drug_Cst) as total_cost,
       SUM(Tot_Clms) as total_claims,
       ROUND(SUM(Tot_Drug_Cst) / SUM(Tot_Clms), 2) as avg_cost_per_claim
FROM Medicare_PartD
WHERE Gnrc_name = 'Adalimumab'
    OR Brnd_Name LIKE 'Amjevita%' 
    OR Brnd_Name LIKE 'Cyltezo%'
    OR Brnd_Name LIKE 'Hyrimoz%'
    OR Brnd_Name LIKE 'Hadlima%'
    AND Tot_Drug_Cst IS NOT NULL AND Tot_Drug_Cst > 0
    AND Prscrbr_Geo_Lvl = 'National'
GROUP BY Gnrc_Name, Brnd_Name
ORDER BY avg_cost_per_claim DESC
;

-- Savings potential calculation ($12.5B opportunity)
WITH expensive_drugs AS (
    SELECT Gnrc_Name, SUM(Tot_Clms) as current_volume,
           ROUND(SUM(Tot_Drug_Cst) / SUM(Tot_Clms), 2) as expensive_price_per_claim
    FROM Medicare_PartD
    WHERE Gnrc_Name IN ('Apixaban', 'Semaglutide', 'Empagliflozin', 'Dulaglutide', 'Adalimumab')
    AND Prscrbr_Geo_Lvl = 'National'
    GROUP BY Gnrc_Name
),
cheap_alternatives AS (
    SELECT Gnrc_Name,
           ROUND(SUM(Tot_Drug_Cst) / SUM(Tot_Clms), 2) as cheap_price_per_claim
    FROM Medicare_PartD
    WHERE Gnrc_Name IN ('Warfarin Sodium', 'Metformin Hcl', 'Adalimumab-Bwwd')
    AND Prscrbr_Geo_Lvl = 'National'
    GROUP BY Gnrc_Name
)
SELECT e.Gnrc_Name as expensive_drug,
       e.current_volume,
       e.expensive_price_per_claim,
       ROUND(e.current_volume * 0.25 * (e.expensive_price_per_claim - c.cheap_price_per_claim), 0) as potential_savings
FROM expensive_drugs e
JOIN cheap_alternatives c ON 
    (e.Gnrc_Name IN ('Apixaban', 'Rivaroxaban') AND c.Gnrc_Name = 'Warfarin Sodium') OR
    (e.Gnrc_Name IN ('Semaglutide', 'Empagliflozin', 'Dulaglutide') AND c.Gnrc_Name = 'Metformin Hcl') OR
    (e.Gnrc_Name = 'Adalimumab' AND c.Gnrc_Name = 'Adalimumab-Bwwd')
ORDER BY potential_savings DESC
;


-- High-ratio state/territory targeting blood thinners
WITH ratio_calculation AS (
    SELECT Prscrbr_Geo_Desc,
           SUM(CASE WHEN Gnrc_Name = 'Apixaban' THEN Tot_Clms ELSE 0 END) as eliquis_claims,
           SUM(CASE WHEN Gnrc_Name = 'Warfarin Sodium' THEN Tot_Clms ELSE 0 END) as warfarin_claims,
           SUM(CASE WHEN Gnrc_Name = 'Apixaban' THEN Tot_Drug_Cst ELSE 0 END) as eliquis_cost
    FROM Medicare_PartD
    WHERE Prscrbr_Geo_Lvl <> 'National'
    GROUP BY Prscrbr_Geo_Desc
)
SELECT *, 
       CASE WHEN warfarin_claims = 0 THEN NULL
            ELSE ROUND(eliquis_claims * 1.0 / warfarin_claims, 2)
       END AS eliquis_warfarin_ratio
FROM ratio_calculation
WHERE eliquis_claims > 100 AND warfarin_claims > 0 
ORDER BY eliquis_warfarin_ratio DESC
;

-- High-ratio state/territory targeting diabetes medication
WITH ratio_calculation AS (
    SELECT Prscrbr_Geo_Desc,
           SUM(CASE WHEN Gnrc_Name IN ('Semaglutide', 'Empagliflozin', 'Dulaglutide') THEN Tot_Clms ELSE 0 END) as brand_name_claims,
           SUM(CASE WHEN Brnd_Name = 'Metformin Hcl' THEN Tot_Clms ELSE 0 END) as metformin_claims,
           SUM(CASE WHEN Gnrc_Name IN ('Semaglutide', 'Empagliflozin', 'Dulaglutide') THEN Tot_Drug_Cst ELSE 0 END) as brand_name_cost
    FROM Medicare_PartD
    WHERE Prscrbr_Geo_Lvl <> 'National'
    GROUP BY Prscrbr_Geo_Desc
)
SELECT *, 
       CASE WHEN metformin_claims = 0 THEN NULL
            ELSE ROUND(brand_name_claims * 1.0 / metformin_claims, 2)
       END AS brand_name_metformin_ratio
FROM ratio_calculation
WHERE brand_name_claims > 100 AND metformin_claims > 0
ORDER BY brand_name_metformin_ratio DESC
;

-- High-ratio state/territory targeting immunosuppressants
WITH ratio_calculation AS (
    SELECT Prscrbr_Geo_Desc,
           SUM(CASE WHEN Gnrc_Name = 'Adalimumab' THEN Tot_Clms ELSE 0 END) as humira_claims,
           SUM(CASE WHEN Gnrc_Name = 'Adalimumab-Bwwd' THEN Tot_Clms ELSE 0 END) as hadlima_claims,
           SUM(CASE WHEN Gnrc_Name = 'Adalimumab' THEN Tot_Drug_Cst ELSE 0 END) as humira_cost
    FROM Medicare_PartD
    WHERE Prscrbr_Geo_Lvl <> 'National'
    GROUP BY Prscrbr_Geo_Desc
)
SELECT *, 
       CASE WHEN hadlima_claims = 0 THEN NULL
            ELSE ROUND(humira_claims * 1.0 / hadlima_claims, 2)
       END AS humira_hadlima_ratio
FROM ratio_calculation
WHERE humira_claims > 100 AND hadlima_claims > 0
ORDER BY humira_hadlima_ratio DESC
;