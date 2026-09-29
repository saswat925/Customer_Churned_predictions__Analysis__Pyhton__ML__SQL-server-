# 📡 Telecom Customer Churn: End-to-End Machine Learning & SQL Analytics

[![GitHub repo](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/saswat925/Customer_Churned_predictions__Analysis__Pyhton__ML__SQL-server-)
[![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/Library-scikit--learn-orange?logo=scikitlearn)](https://scikit-learn.org/)
[![Database](https://img.shields.io/badge/Database-MS%20SQL%20Server-red?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An end-to-end data science, machine learning, and relational database project analyzing subscriber attrition across **243,553 telecom records**. The repository implements strict data hygiene, Benjamini-Hochberg FDR testing, leak-free Scikit-Learn pipelines, statistical sanity checks (label permutation, bootstrap CIs), and automated SQL Server integration.

---

## 📌 Executive Summary

* **Objective:** Predict subscriber churn and uncover operational churn drivers across four major operators: **Airtel, Reliance Jio, Vodafone, and BSNL**.
* **Key Finding:** Despite evaluating multiple tuned architectures (Logistic Regression, Decision Trees, Random Forests, and HistGradientBoosting), model performance peaked at **ROC-AUC ~0.5048**, performing equivalently to a no-skill coin toss.
* **Audit & Root Cause:** 
  * Chi-Square tests of independence between geographic fields (`state` vs. `postal_region`: $p = 0.523$, `state` vs. `city`: $p = 0.982$) demonstrated that location attributes were independently randomized.
  * Feature-to-target correlations hovered near zero ($\vert{}r\vert{} \le 0.0034$), indicating that churn in this dataset behaves as independent random noise.
* **Strategic Takeaway:** Demographic and basic usage totals fail to predict churn. Further algorithm complexity is ineffective without higher-order behavioral features (e.g., dropped call rates, QoS telemetry, complaint logs, contract commitment).

---

## 🏗️ Project Architecture

```text
├── outputs/
│   ├── 01_telecom_churn_cleaned.csv         # Cleaned, feature-engineered dataset (243,553 rows)
│   ├── 02_model_comparison.csv              # Test set evaluation across 8 model configurations
│   ├── 03_cross_validation_results.csv      # 5-fold stratified CV performance metrics
│   ├── 04_statistical_tests.csv             # Mann-Whitney U & Chi-Square tests (raw vs. FDR)
│   ├── 05_partner_state_churn.csv           # Regional partner-state churn rates & Z-scores
│   ├── 06_permutation_importance.csv        # Permutation drop metrics
│   ├── 07_test_predictions.csv              # Out-of-sample predictions & probabilities
│   └── churn_model.joblib                   # Serialized Random Forest pipeline artifact
├── telecom_churn_project.ipynb              # Complete end-to-end workflow notebook
├── README.md
🔍 Data Quality Audit & Feature Engineering1. Data Cleaning & Anomaly FlaggingImpossible Values: Usage counts cannot be negative. Negative records were identified in calls_made (2.76%), sms_sent (3.03%), and data_used (2.48%).Leakage-Safe Imputation: Rather than dropping rows or applying dataset-wide medians, boolean indicators (*_was_negative) were preserved to capture potential logging errors, and invalid values were converted to NaN for in-pipeline median imputation.2. Feature EngineeringAccount Age (tenure_months): Measured elapsed time relative to the maximum observed registration date.Usage Intensity: Normalized calls, SMS, and data volume per month of tenure (*_per_tenure).Interaction Features: Combined operator and administrative territory (partner_state).📊 Statistical Testing & Hypothesis VerificationTo confirm whether observed demographic differences were statistically meaningful or artifacts of massive sample size ($N \approx 243.5\text{k}$), tests were combined with Benjamini-Hochberg (FDR) corrections:FeatureTest AppliedEffect Size MetricEffect ValueRaw p-valueFDR Adjusted pSignificant (α=0.05)?genderChi-SquareCramér's V0.00510.01220.1952No (False Positive)estimated_salaryMann-Whitney UProb. of Superiority0.50240.10030.4263Nodata_usage_groupChi-SquareCramér's V0.00490.12220.4263Nocalls_madeMann-Whitney UProb. of Superiority0.49830.25780.4498Notenure_monthsMann-Whitney UProb. of Superiority0.50120.41490.5768Nopartner_stateChi-SquareCramér's V0.02250.19590.4498No🤖 Machine Learning Experiments & ValidationModels were evaluated using Scikit-Learn Pipeline architectures to avoid data leakage during cross-validation and hyperparameter search.Raw Input ──► Stratified Split (80/20) ──► Median Imputer ──► Scaler / OneHotEncoder ──► Estimator
Out-of-Sample Evaluation (Test Set: 48,711 rows)ModelAccuracyPrecisionRecallF1-ScoreROC-AUCPR-AUCRandom Forest0.52720.20240.46210.28150.50480.2037Logistic Regression0.52060.20110.46800.28130.50400.2032HistGradientBoosting (Tuned)0.50630.20200.49580.28700.50360.2027HistGradientBoosting (Base)0.51600.19880.46670.27880.49940.2006Decision Tree0.42670.19860.61270.30000.49500.1983Baseline: Majority Class0.79950.00000.00000.00000.50000.2005Baseline: Stratified Random0.67750.19450.19390.19420.49630.1993Sanity Checks & Signal VerificationShuffled-Label Test: Retraining on permuted targets produced an ROC-AUC of 0.4951 (vs. 0.5040 on empirical data).Bootstrap Confidence Interval: 200-sample bootstrap on Random Forest test probabilities gave a 95% CI of [0.4984, 0.5117]. Since this interval spans 0.50, the model cannot be distinguished from random guessing.Permutation Importance: The top ranking feature (data_per_tenure) resulted in an AUC decrease of only 0.0057, verifying the lack of genuine predictive signal.🗄️ SQL Server Database & Business AnalyticsThe cleaned pipeline data was ingested into Microsoft SQL Server via SQLAlchemy and pyodbc for relational analysis:SQL-- Partner-wise churn distribution
SELECT
    telecom_partner,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    CAST(SUM(churn) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate
FROM dbo.Telecom_Churn
GROUP BY telecom_partner
ORDER BY churn_rate DESC;
Relational FindingsBase Churn Rate: 20.05% overall (48,827 churned / 194,726 retained).Even Carrier Distribution: Churn rates showed minimal variance across operators:Airtel: 20.37%Reliance Jio: 20.02%Vodafone: 19.95%BSNL: 19.86%Average Account Duration: Retained customers averaged 20.05 months, while churned customers averaged 20.00 months.⚡ Quickstart1. Clone & Set Up Virtual EnvironmentBashgit clone [https://github.com/saswat925/Customer_Churned_predictions__Analysis__Pyhton__ML__SQL-server-.git](https://github.com/saswat925/Customer_Churned_predictions__Analysis__Pyhton__ML__SQL-server-.git)
cd Customer_Churned_predictions__Analysis__Pyhton__ML__SQL-server-
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install numpy pandas matplotlib seaborn scipy scikit-learn joblib sqlalchemy pyodbc
2. Run the WorkflowExecute the notebook telecom_churn_project.ipynb to recompute the data quality audit, model benchmarks, and CSV/joblib artifacts into the outputs/ folder.3. Load Model ArtifactPythonimport joblib

pipeline = joblib.load("outputs/churn_model.joblib")
print("Model step:", pipeline.named_steps["model"])

***

<FollowUp label="Want instructions on how to push this directly to your GitHub repository from the command line?" query="Show me the step-by-step
