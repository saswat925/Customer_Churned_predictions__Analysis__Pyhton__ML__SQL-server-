use  Telecom_Churn_DB;
go
--check data
select * from Telecom_Churn;
select count(*) from Telecom_Churn;--243553 rows

--1. Overall Churn Analysis — KPI
SELECT
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM Telecom_Churn;
--total_customers	churned_customers	retained_customers	churn_rate
       --243553	        48827	           194726	        20.05

--2. Telecom Partner-wise Churn
SELECT
    telecom_partner,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY telecom_partner
ORDER BY churn_rate DESC;
--telecom_partner	total_customers	churned_customers	churn_rate
--Airtel	              60905	        12404	         20.37
--Reliance Jio	          61123	        12234	         20.02
--Vodafone	              60802	        12129	         19.95
--BSNL	                  60723	        12060	         19.86

--airtel face the highst churn rate 20.37

--3. State-wise Churn
SELECT
    state,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY state
ORDER BY churn_rate DESC;
---Jharkhand  is the highst risk churn rate 21.12
---2nd highest risk in churn is karnatak 20.71
---4. Age Group vs Churn
SELECT
    age_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY age_group
ORDER BY churn_rate DESC;
--age_group	               total_customers	churned_customers	churn_rate
--Middle Adults	             42710	             8648	        20.25
--Senior Adults	             85896	             17229	        20.06
--Early Adults	             42255	             8451	        20.00
--Young Adults	             29874	             5972	        19.99
--Mature Adults	             42818	             8527	        19.91
--middle adults are highst chrun rate 20.25

--5. Data Usage vs Churn
SELECT
    data_usage_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY data_usage_group
ORDER BY churn_rate DESC;
--Business Insight

--The churn rates across data usage groups are very similar, ranging from 19.79% to 20.28%.

--Medium data users have the highest churn rate at 20.28%.
--High data users have a churn rate of 20.24%.
--Very High data users have a churn rate of 19.89%.
--Low data users have the lowest churn rate at 19.79%.

--6. Call Usage vs Churn
SELECT
    call_usage_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY call_usage_group
ORDER BY churn_rate DESC;
--Business Insight – Call Usage vs Churn

--The churn rates across call usage groups are also very similar, ranging from 19.91% to 20.18%.

--High call users have the highest churn rate at 20.18%.
--Very High call users have a churn rate of 20.12%.
--Medium call users have a churn rate of 20.00%.
--Low call users have the lowest churn rate at 19.91%.

--7. Tenure vs Churn
SELECT
    churn,
    COUNT(*) AS customers,
    CAST(AVG(tenure_months) AS DECIMAL(10,2)) AS avg_tenure_months
FROM dbo.Telecom_Churn
GROUP BY churn;
--Business Insight – Tenure vs Churn
--The average tenure of both retained and churned customers is almost identical:
--Retained customers (Churn = 0): 20.05 months
--Churned customers (Churn = 1): 20.00 months

--8. High-Risk Customer Segment
SELECT
    telecom_partner,
    age_group,
    data_usage_group,
    call_usage_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM Telecom_Churn
GROUP BY
    telecom_partner,
    age_group,
    data_usage_group,
    call_usage_group
HAVING COUNT(*) >= 100
ORDER BY churn_rate DESC;
--Business Insight
--The highest churn rate is 25.23%, observed for Airtel – Early Adults – Low Data Usage – Low Call Usage. The next highest is 24.63% for Vodafone – Early Adults – High Data Usage – High Call Usage.
--However, most segments are around 19–22% churn, so these combinations should be treated as higher-risk segments, not as proof that each individual factor causes churn.
--Business Recommendation
--The company should prioritize targeted retention campaigns for high-churn segments, especially combinations involving Airtel/Vodafone and Early Adults, while investigating other factors that may explain the differences.
-- 9. Gender-wise Churn Analysis
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY gender
ORDER BY churn_rate DESC;
--Gender shows almost no relationship with churn — 20.30% (F) vs 19.88% (M), a gap of just 0.42 points, too small to be practically meaningful. Other factors (tenure, contract type, charges) are far more likely to drive churn than gender.

-- 10. Dependents Group vs Churn

SELECT
    dependents_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY dependents_group
ORDER BY churn_rate DESC;
--No — churn is nearly identical: 20.23% (no dependents) vs 20.00% (has dependents), a negligible 0.23-point gap. Dependents don't appear to meaningfully influence churn in this data.

-- 11. Estimated Salary vs Churn

SELECT
    CASE
        WHEN estimated_salary < 25000 THEN 'Low Salary'
        WHEN estimated_salary < 50000 THEN 'Lower-Middle Salary'
        WHEN estimated_salary < 100000 THEN 'Middle Salary'
        ELSE 'High Salary'
    END AS salary_group,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,

    CAST(
        SUM(churn) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Telecom_Churn

GROUP BY
    CASE
        WHEN estimated_salary < 25000 THEN 'Low Salary'
        WHEN estimated_salary < 50000 THEN 'Lower-Middle Salary'
        WHEN estimated_salary < 100000 THEN 'Middle Salary'
        ELSE 'High Salary'
    END

ORDER BY churn_rate DESC;

--salary_group	      total_customers	churned_customers	retained_customers	churn_rate
--Lower-Middle Salary	46835	                9459	         37376	         20.20
--Middle Salary	        93730	                18924	         74806	         20.19
--High Salary	        93694	                18604	         75090	         19.86
--Low Salary	         9294	                 1840	          7454	         19.80
--Churn rates are nearly flat across salary bands (19.80%–20.20%), a range of just 0.4 points. Estimated salary shows no meaningful relationship with churn.

-- 12. SMS Usage vs Churn

SELECT
    CASE
        WHEN sms_sent < 100 THEN 'Low SMS'
        WHEN sms_sent < 300 THEN 'Medium SMS'
        WHEN sms_sent < 500 THEN 'High SMS'
        ELSE 'Very High SMS'
    END AS sms_usage_group,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,

    CAST(
        SUM(churn) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Telecom_Churn

GROUP BY
    CASE
        WHEN sms_sent < 100 THEN 'Low SMS'
        WHEN sms_sent < 300 THEN 'Medium SMS'
        WHEN sms_sent < 500 THEN 'High SMS'
        ELSE 'Very High SMS'
    END

ORDER BY churn_rate DESC;
--sms_usage_group	total_customers	churned_customers	churn_rate
--Low SMS	               243553	           48827	20.05

-- 13. Customer Usage Comparison

SELECT
    churn,

    COUNT(*) AS customers,

    CAST(AVG(age) AS DECIMAL(10,2)) AS avg_age,

    CAST(AVG(num_dependents) AS DECIMAL(10,2)) AS avg_dependents,

    CAST(AVG(estimated_salary) AS DECIMAL(12,2)) AS avg_salary,

    CAST(AVG(calls_made) AS DECIMAL(10,2)) AS avg_calls,

    CAST(AVG(sms_sent) AS DECIMAL(10,2)) AS avg_sms,

    CAST(AVG(data_used) AS DECIMAL(10,2)) AS avg_data_used,

    CAST(AVG(tenure_months) AS DECIMAL(10,2)) AS avg_tenure

FROM Telecom_Churn

GROUP BY churn
ORDER BY churn;
--churn	customers	avg_age	avg_dependents	avg_salary	avg_calls	avg_sms	avg_data_used	avg_tenure
   --0	    194726	46.00	1.00	         85083.00	   50.47	24.79	   5126.14	    20.05
   --1	     48827	46.00	1.00	         84771.00	   50.62	24.71	   5137.11	    20.00

 -- 15. Telecom Partner + State Churn

SELECT
    telecom_partner,
    state,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,

    CAST(
        SUM(churn) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS churn_rate

FROM dbo.Telecom_Churn

GROUP BY
    telecom_partner,
    state

HAVING COUNT(*) >= 100

ORDER BY churn_rate DESC;  

--Airtel is the top-churning partner in 15 of 28 states, especially across hilly/northeastern regions (Himachal Pradesh, Mizoram, Assam, Arunachal Pradesh, Nagaland) — suggesting a possible network coverage or service quality issue in terrain-challenged areas.
--Reliance Jio leads churn in 7 states, with its worst case in Jharkhand at 23.21% — the highest churn rate in the entire dataset.
--Unlike gender, salary, or city (which showed flat/negligible variation), partner + state combinations reveal real, actionable signal — worth escalating to regional teams for investigation.

