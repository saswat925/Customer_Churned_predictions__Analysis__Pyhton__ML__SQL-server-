# 📡 Telecom Customer Churn: End-to-End Data Science, Machine Learning & SQL Server Project

[![GitHub repo](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/saswat925/Customer_Churned_predictions__Analysis__Pyhton__ML__SQL-server-)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/Library-scikit--learn-orange?logo=scikitlearn)](https://scikit-learn.org/)
[![Database](https://img.shields.io/badge/Database-MS%20SQL%20Server-red?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An end-to-end data science and relational database warehouse project analyzing attrition dynamics across **243,553 customers** and **14 raw features**. The project implements rigorous exploratory data analysis, geographic consistency audits, leak-free Scikit-Learn pipelines, Benjamini-Hochberg FDR statistical testing, ML benchmarking, empirical sanity checks (label shuffling, bootstrap CI, permutation importance), and production migration to Microsoft SQL Server (`Telecom_Churn_DB`).

---

## 📋 Table of Contents
1. [Project Overview & Dataset Dictionary](#-project-overview--dataset-dictionary)
2. [Executive Summary & Core Findings (TL;DR)](#-executive-summary--core-findings-tldr)
3. [Data Quality Audit & Cleaning](#-data-quality-audit--cleaning)
4. [Feature Engineering](#-feature-engineering)
5. [Exploratory Data Analysis (EDA)](#-exploratory-data-analysis-eda)
6. [Statistical Hypothesis Testing & FDR Correction](#-statistical-hypothesis-testing--fdr-correction)
7. [Machine Learning Pipeline & Baseline Comparison](#-machine-learning-pipeline--baseline-comparison)
8. [Cross-Validation & Hyperparameter Tuning](#-cross-validation--hyperparameter-tuning)
9. [Signal Verification & Sanity Checks](#-signal-verification--sanity-checks)
10. [Generated Project Artifacts & Export](#-generated-project-artifacts--export)
11. [SQL Server Data Warehouse & Analytical Queries](#-sql-server-data-warehouse--analytical-queries)
12. [Strategic Business Recommendations & Next Steps](#-strategic-business-recommendations--next-steps)
13. [Setup & Execution Guide](#-setup--execution-guide)

---

## 📌 Project Overview & Dataset Dictionary

* **Goal:** Predict which telecom subscribers will churn and identify the root business drivers of attrition.
* **Volume:** 243,553 rows $\times$ 14 raw columns (Memory footprint: ~26.0 MB).

| Column Name | Type | Description |
| :--- | :---: | :--- |
| `customer_id` | `int64` | Unique customer identification number (1 to 243,553) |
| `telecom_partner` | `str` | Network provider: Airtel, Reliance Jio, Vodafone, BSNL |
| `gender` | `str` | Subscriber gender: Female (F), Male (M) |
| `age` | `int64` | Subscriber age in years (Range: 18 to 74) |
| `state` | `str` | Administrative state (28 distinct states) |
| `city` | `str` | Administrative city (6 distinct metro hubs) |
| `pincode` | `int64` | Postal identification code (213,442 unique values) |
| `date_of_registration` | `str` | Subscription creation timestamp (2020-01-01 to 2023-05-04) |
| `num_dependents` | `int64` | Dependent family count (Range: 0 to 4) |
| `estimated_salary` | `int64` | Estimated annual income (Range: ₹20,000 to ₹149,999) |
| `calls_made` | `int64` | Voice calls recorded (Range: -10 to 108) |
| `sms_sent` | `int64` | Text messages transmitted (Range: -5 to 53) |
| `data_used` | `int64` | Volume of data consumed in MB (Range: -987 to 10,991) |
| `churn` | `int64` | **Target variable:** 1 = Churned (20.05%), 0 = Retained (79.95%) |

---

## 💡 Executive Summary & Core Findings (TL;DR)

1. **Model Signal Failure:** Every trained classifier (Logistic Regression, Decision Tree, Random Forest, HistGradientBoosting) scored **ROC-AUC ~ 0.50**, exactly matching an untrained dummy classifier.
2. **Stable Cross-Validation:** 5-fold cross-validation confirmed this failure is strictly systemic (**0.4985 to 0.5014** across all folds).
3. **Synthetic / Noise Footprint:** 
   * Geographical attributes contradict reality: `state`, `city`, and `pincode` are mutually independent (e.g., Karnataka linked to Kolkata; Chi-square $p = 0.523$ and $p = 0.982$).
   * Absolute linear correlation with churn across all features peaks at an imperceptible **$\vert{}r\vert{} = 0.0034$**.
4. **Definitive Conclusion:** With demographic and volumetric usage data alone, **individual churn cannot be predicted**. The bottleneck is strictly **the data**, not hyperparameter optimization or algorithmic selection.

---

## 🧹 Data Quality Audit & Cleaning

### 1. Duplicates & Null Audit
* **Duplicate Rows:** 0 | **Duplicate Customer IDs:** 0
* **Registration Date:** Converted to datetime format (`2020-01-01` to `2023-05-04`). Unparseable entries: 0.

### 2. Negative Value Quarantine (Usage Logs)
Usage metrics cannot take negative values in real telecommunications systems. Instead of dropping records or silent median overwriting, boolean indicator flags were created, and invalid figures were masked with `np.nan` for leak-free median imputation inside pipeline transformers:

| Usage Column | Negative Rows | Share of Total | Churn Rate When Negative | Processing Strategy |
| :--- | :---: | :---: | :---: | :--- |
| `calls_made` | 6,713 | 2.76% | 20.29% | Flag `calls_made_was_negative`, mask to `NaN` |
| `sms_sent` | 7,375 | 3.03% | 20.83% | Flag `sms_sent_was_negative`, mask to `NaN` |
| `data_used` | 6,050 | 2.48% | 20.73% | Flag `data_used_was_negative`, mask to `NaN` |

*Overall churn baseline: **20.05%**.*

### 3. Geographic Consistency Audit
In real administrative records, postal codes and cities correlate deterministically with their respective states.
* **City Dispersion:** The average share of the most dominant city within a state is **0.172** (pure random uniform distribution across 6 cities is $\frac{1}{6} \approx 0.167$).
* **State vs. Postal Region (`pincode[0]`):** Chi-Square test $p = \mathbf{0.523}$
* **State vs. City:** Chi-Square test $p = \mathbf{0.982}$
* **Verdict:** High $p$-values confirm that geographic columns are statistically independent, demonstrating that location values were randomly assigned in this synthetic dataset.

---

## 🛠️ Feature Engineering

All engineered features were created on a row-by-row basis to eliminate data leakage:
* **Account Age (`tenure_months`):** Months between registration and dataset reference cutoff:
  $$\text{tenure\_months} = \frac{\text{reference\_date} - \text{date\_of\_registration}}{30.44}$$
* **Temporal Attributes:** Extracted `registration_month` and `registration_dayofweek`.
* **Usage Intensity Ratios:** Normalized usage per unit of account age:
  $$\text{calls\_per\_tenure} = \frac{\text{calls\_made}}{\text{tenure\_months} + 1}$$
  $$\text{sms\_per\_tenure} = \frac{\text{sms\_sent}}{\text{tenure\_months} + 1}$$
  $$\text{data\_per\_tenure} = \frac{\text{data\_used}}{\text{tenure\_months} + 1}$$
* **Interaction Feature:** Cross-product column `partner_state` (`telecom_partner` + `_` + `state`).

```text
Final Feature Breakdown:
├── Numeric (15): age, num_dependents, estimated_salary, calls_made, sms_sent, data_used, 
│                 tenure_months, registration_month, registration_dayofweek, calls_per_tenure, 
│                 sms_per_tenure, data_per_tenure, calls_made_was_negative, sms_sent_was_negative, 
│                 data_used_was_negative
├── Categorical (5): telecom_partner, gender, state, city, partner_state
└── Dropped (4): customer_id, date_of_registration, pincode, postal_region
