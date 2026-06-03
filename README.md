# Medicare Part D Cost Concentration Analysis

# Project Background & Overview

Medicare Part D provides prescription drug coverage to over 56 million Americans. To promote transparency and support research, the Centers for Medicare & Medicaid Services (CMS) publishes the Part D Prescribers Dataset, which contains detailed information on prescription drug events (PDEs) submitted by providers enrolled in Medicare Part D. 

This project specifically uses the 2023 public dataset, “Medicare Part D Prescribers - by Geography and Drug” which includes a total **1.6B+ claims** across each state and U.S. territory. This comprehensive review demonstrates a systematic, data-driven methodology to uncover utilization management gaps and identify potential savings for Medicare’s Finance and Pharmacy Benefits Management teams.

**Insights and recommendations are provided on the following key areas:**

- **Cost Concentration Analysis**: Analysis of the distribution of total drug costs for the top selling drugs and drug categories nationally, focusing on Percentage of Total and Cost Per Claim.
- **Price Differential Discovery**: Analysis of price differences between brand name drugs and their lower-cost generic equivalent through Average Cost Per Claim among the highest-selling drug categories.
- **Geographic Cost Distribution**: Calculation of brand-to-generic prescription ratios of the highest-selling drug categories by state/territory. This narrows the areas of approach that will result in the highest cost-saving outcomes.
- **Performance Tracking Framework**: Two core key performance indicators were recommended to monitor savings progress:  Drug Cost Concentration and Generic Substitution Rate.

The SQL queries used to inspect, clean, and perform quality checks for this analysis can be found [here](https://github.com/kochoa95/Medicare-Part-D-Cost-Concentration-Analysis/blob/main/datacleaningchecks.session.sql).

Targeted queries regarding various business insights can be found [here](https://github.com/kochoa95/Medicare-Part-D-Cost-Concentration-Analysis/blob/main/exploratoryanalysis.session.sql).

KPI tracking and performance monitoring queries can be found [here](https://github.com/kochoa95/Medicare-Part-D-Cost-Concentration-Analysis/blob/main/kpitracking.session.sql).

# Data Structure & Initial Checks

The Medicare Part D prescriber database consists of one main table: **Medicare_PartD**, containing  **116k rows** and **22 fields.**
<img width="1055" height="330" alt="ERD" src="https://github.com/user-attachments/assets/2bc7fd46-f901-4174-b538-945e77a9f740" />

**Key Data Components:**

- **Prescriber Information:** Provider metrics and geographic distribution
- **Drug Information:** Generic names, brand names, and special therapeutic classifications
- **Cost Data:** Total drug costs and prescription fill pricing
- **Volume Metrics:** Total claims, prescription counts and patient/beneficiary populations

Prior to beginning the analysis, comprehensive quality control checks were conducted to ensure data integrity and gain familiarity with the dataset structure. These checks validated data completeness, identified potential outliers, and confirmed the dataset's suitability for utilization management analysis.

# Executive Summary

## **Overview of Findings**

**Extreme market dominance revealed**: Out of 3600+ unique drugs prescribed in 2023, the top 10  account for **25.79%** of all Medicare Part D spending, with the top 5 drugs accounting for nearly 20%. The blood thinner Eliquis is the #1 most expensive drug in the list, which accounts for **6.6%** (a total cost of over **$18B)** in expenses alone—a concentration level that indicates a systemic market capture rather than isolated pricing issues.

**Volume and price are misaligned**: Eliquis dominates with 21 million prescriptions at $860 each while the clinically equivalent Warfarin has only 5 million prescriptions at $14 each, representing a complete market reversal where expensive options became default choices. Other leading drug categories show similar discrepancies in total claims and average cost per claim.

**$12.5B savings opportunity quantified**: The analysis shows significant savings opportunities for generic turnover. Even a conservative 25% generic switch among the top selling drugs shows a significant savings impact in the billions, with Ozempic/Jardiance/Trulicity → Metformin ($6.6B), Eliquis → Warfarin ($4.5B), and Humira → Hadlima ($1.3B).

**Geographic cost patterns identified**: Analysis revealed states and territories with the highest concentration of prescribers with expensive-to-cheap drug ratios, providing targeted intervention strategies for regions driving disproportionate costs and therefore creating the highest savings impact.

# Insights Deep Dive

## **1. Cost Concentration Trends**

Analysis of  Medicare Part D data exposed a disproportionately high cost concentration among the top 10 out of 3600+ unique prescription drugs.

- **Top 10 drugs account for** 25.8% of all Medicare Part D spending
- **Top 5 drugs**: 18.1%
- **Eliquis alone**: 6.6%

**Two Distinct Patterns Emerged**

- **Blood Thinners Dominating the Market**
    
    Eliquis (6.6% prescription rate) and Xarelto (2.3%) have largely replaced generic warfarin sodium (0.03%) for common conditions like atrial fibrillation and deep vein thrombosis. These newer blood thinners cost drastically more but are being prescribed to millions of patients as the default choice, not considering the reality that many high-risk patients are stable on warfarin for years and often stay on it indefinitely.
    
- **The Diabetes Drug Revolution**
    
    Ozempic (3.3%), Jardiance (3.2%), and Trulicity (2.7%) represent a fundamental shift toward more expensive diabetes treatments, with a combined 9.2% of all prescription drug expenditures and $25.3B+ of the program market. While these drugs may offer clinical advantages, they are prescribed at massive volumes as a first-line treatment despite metformin's (0.09%) proven effectiveness for treating Type 2 diabetes at a fraction of the cost ($10.37 vs $1265.54 average cost per claim).

<img width="1415" height="653" alt="Tableau Top 10 Concentration" src="https://github.com/user-attachments/assets/f04ddfd1-ef17-41ce-9ec0-b7033ecb062f" />


<p align="center">
  <img src="https://public.tableau.com/views/MedicarePartDCostConcentrationAnalysis/CC?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link">
</p>


## **2. Price-Volume Inversion Discovery**

- **Extreme Price Gaps Identified.** Analysis revealed price differentials of 61x for blood thinners (Eliquis $862 vs Warfarin $14), 128x for diabetes medications (Ozempic $1,327 vs Metformin $10), and 7x for biologic immunosuppressants (Humira $9231 vs Hadlima $1268) for therapeutically equivalent medications, highlighting fundamental cost structure differences rather than just modest price premiums.
- **Volume-Price Inversion Pattern.** Expensive drugs consistently capture higher prescription volumes than cheaper alternatives. Eliquis has 21 million prescriptions while warfarin sodium has 5 million, despite the 61x cost difference, indicating systematic market reversal where expensive options became default choices for first-line treatment.
- **High Price + High Volume = Maximum Impact Pattern.** Identified drugs that represent the worst-case scenario for cost control—premium pricing combined with market dominance, creating opportunities for high-impact intervention strategies.

<img width="800" height="550" alt="Tableau Price Diff" src="https://github.com/user-attachments/assets/1a4fc1d0-a489-4511-851a-937f2b0ab0f6" />


## **3. The $12.5B Savings Calculation Discovery**

- **Conservative Methodology Validation.** Even a conservative 25% patient switching assumption (leaving 75% on more expensive drugs) to account for clinical contraindications, treatment failures, and implementation challenges, still displays identified massive savings potentials.
- **Sensitivity Analysis Robustness.** Testing revealed savings potential ranges from $12.5B (20% switch) to $25B (50% switch), demonstrating that even if switching assumptions are overly optimistic, savings remain enormous due to extreme price differentials.
- **Specific Drug Target Quantification.** Analysis identified exact savings opportunities: Eliquis → Warfarin ($4.5B), Ozempic/Jardiance/Trulicity → Metformin ($6.6B), and Humira → Hadlima ($1.3B), providing actionable intervention targets with quantified financial impact.
- **Mathematical Reality of Price Differentials.** Discovery that savings potential scales with price gaps rather than volume alone. Because expensive drugs cost 7-128x more, even modest switching rates generate substantial financial impact regardless of conservative clinical assumptions.

<img width="949" height="550" alt="Tableau Savings Potential" src="https://github.com/user-attachments/assets/af7281d7-506a-4ae6-beb8-95f07466fb74" />

## **4. Prescriber Behavior Pattern Analysis**

- **Geographic Prescription Ratio Disparities**: Analysis exposed states and areas that have the highest expensive-to-cheap prescription ratios for Eliquis:Warfarin (as high as >6:1) and Humira:Hadlima (as high as >2000:1). No strong evidence of regional trends. Given lack of demographic data, this could suggest a myriad of potential issues, including local practice norms, pharmacy benefits management penetration disparities, provider network issues, etc.
- **Ratio-Based Targeting Strategy:** From a utilization management perspective, analysis of the State Generic Substitution Rate (see KPI’s below) narrows the areas of approach that would result in the highest cost-saving outcomes.

The link to a tree maps dashboard for top drug categories (blood thinners, diabetes medications, biologic immunosuppressants) with more detailed metrics can be viewed here.

# KPI’s & Recommendations

Based on the insights and findings above, we would recommend the **Pharmacy Benefits Management (PBM) and Finance teams** to consider the following:

**Important note:** Interventions are framed in the context of a conservative 25% national generic substitution rate goal to prioritize **clinically appropriate generic optimization**, as many patients can and will have higher health outcomes from brand name drugs over their generic or biosimilar equivalents.

## **1. Addressing the 25.8% Cost Concentration**

The concentration of the top 10 drugs accounting for over one-fourth of drug costs creates a huge opportunity for targeted high-impact interventions. 

**Targeted step therapy** **and** **provider education programs** can be implemented within 6-12 months using specific geographic and drug targeting strategies identified in this analysis. 

**Pairing savings programs with patient education** can ease patient concerns/hesitations with switching medications and reduce therapy abandonment or member dissatisfaction. 

## **2. Focus on Patent Expired Biologics**

Humira’s main patent protection expired in the U.S. in January 2023. Since then, many clinically equivalent biosimilars ****are now widely available, creating opportunities for **biosimilar adoption** and significant cost savings. **Hadlima** shows the highest potential savings among Humira biosimilars at an estimated 1.3B$ per year. 

The recommendation is to **mandate biosimilar trials** for patients requiring these medications while **requiring clinical justification** for continued use of more expensive brand name drugs over their biosimilar alternatives. This policy leverages the natural transition period following patent expiration to systematically shift utilization toward lower-cost therapeutic equivalents without compromising patient care quality.

## **3. Target High Ratio Brand-Name Prescription Rates**

Blood thinners and diabetes drugs represent the highest-impact opportunity, driving a combined $11B+ in potential savings through price differentials of 61-128x between brand and generic alternatives among Eliquis and Ozempic alone. 

The strategy focuses on **implementing mandatory step therapy protocols for Eliquis and expensive diabetes medications**, requiring patients to trial lower-cost alternatives like warfarin and metformin before accessing brand-name drugs. This approach targets the optimal balance of addressing high prescription volume and substantial cost differences, creating a pathway to $4.5B in blood thinner savings and $6.6B in diabetes drug savings annually.

## **4. Target Geographic Prescriber-Driven Cost Patterns**

The analysis spotlights states and territories that disproportionately prescribe expensive alternatives when lower-cost options are clinically appropriate, creating actionable targeting criteria for prior authorization requirements and provider education programs.

**Enhanced prior authorization protocols and provider education programs** should be implemented for prescribers in regions demonstrating expense ratios above 3:1 for drugs like Eliquis versus warfarin or Humira versus Hadlima. 

**Pilot programs before national rollout** in the regions with the lowest generic substitution rate (see KPI’s below) by drug can be used to test interventions, monitor outcomes, and then scale successful programs rather than immediately enforcing broad switching.

## Key Performance Indicators

Monthly dashboard performance tracking of KPI’s ensures accountability and measures real-time progress toward cost reduction goals. The KPI’s are calculated as follows:

## **1. Drug Cost Concentration**

Top 10 Drug Costs / Total Drug Costs × 100

**Current**: 25.79% concentration 

**Target**: <20% within 12 months 

## **2. National & State/Territory Generic Substitution Rate**

Generic Claims / (Generic + Brand Claims) × 100

**Current National Rate**: 

- Hadlima (immunosuppressants) = 0.03%
- Warfarin (blood thinners) = 17%
- Metformin (diabetes) = 60.67%

**Target**: 

- Hadlima (immunosuppressants) Achieve 25% within 12 months (+25%)
- Warfarin (blood thinners): Achieve 25% within 12 months (+8%)
- Metformin (diabetes): Given current high generic rate, monito
- **Method**: Target bottom 20% states for intervention

# Caveats, Assumptions, & Limitations

**Data Redaction by CMS**

In order to prevent potential re-identification and protect beneficiary privacy, CMS has redacted any data lines in the “Medicare Part D Prescribers - by Geography and Drug” dataset data file that were based on **information from 10 or fewer individual claims and are indicated by a null, and are also not included in the analysis.**

**Total Drug Cost Considerations**

The total drug costs included in the data reflect the prescription drug costs incurred by Medicare Part D beneficiaries, including costs that are paid by Medicare, by beneficiaries, and by third-party payors. In addition, the **Part D spending metrics do not reflect any manufacturers’ rebates or other price concessions** as CMS is prohibited from publicly disclosing such information.

**Clinical Substitution Assumptions**

The analysis and recommendations assume that at least 25% of patients on high-cost drugs can safely switch to cheaper alternatives, although many may require the higher-cost medication due to contraindications, comorbidities, implementation failure, or clinical needs.

**No Time-Based Trends**

Data is a single point-in-time snapshot with no seasonal or longitudinal trends, limiting analysis of how prescribing patterns changed throughout the year.

# Technical Details

Link to Medicare Part D data can be found [here](https://data.cms.gov/provider-summary-by-type-of-service/medicare-part-d-prescribers/medicare-part-d-prescribers-by-geography-and-drug)

Technology Used

- **Excel**: data extraction, transformation, and initial advanced exploratory data analysis (EDA) via interactive pivot tables and pivot charts.
- **SQL**: exploratory data analysis of cost and claims data
- **PostgreSQL and Visual Studio Code**: database management and advanced data manipulation
- **Tableau**: data visualization and data story telling
