# Allison Sibrian - Challenge 1 Analysis

## Overview
This project investigates the hypothesis that weather events drive specific spikes in farmer questions on the Producers Direct platform. By integrating monthly ERA5 climate data with 5 years of farmer question history across Kenya, Uganda, and Tanzania, this analysis focused on predicting topic inquiry volume.

Note: Due to the massive dataset size (21M rows), this analysis was conducted on a stratified 0.5% sample.

## Research Questions
- Question 1: Do specific weather events trigger predictable spikes in farmer questions?
- Question 2: Is there a temporal lag between the weather event and the farmer's question (e.g., biological pest lifecycles)?
- Question 3: Can machine learning models predict the volume of farmers' questions based solely on country-level weather data?

## Methodology

### Data Sources
- Producers Direct Dataset: Obtained the de-duplicated farmer questions split by language from the raw data set.
- Global Historical Climatology Network daily (GHCNd): Pre-processed in Google Colab data to obtain Kenya, Tanzania, and Uganda stations data for EDA.
- ERA5 Climate Reanalysis Data: Monthly aggregates for Total Precipitation (prcp), Maximum Temperature (tasmax), and Minimum Temperature (tasmin) for Kenya, Uganda, and Tanzania.

### Approach
1. **Step 1**: Data processing, loading, and initial exploration
2. **Step 2**: Translation & Cleaning 
3. **Step 3**: Topic Categorization
4. **Step 4**: Aggregation & Feature Engineering
5. **Step 5**: Visualizations and Predictive Modeling

### Tools and Technologies
- **Programming Language**: Python 3.11
- **Key Libraries**: pandas, numpy, duckdb, matplotlib, seaborn, nltk, scikit-learn, etc. 

## Use of Generative AI

### Tools Used
- **Gemini (Google's AI model).**: Used to preprocess the 21M row raw dataset, ghcnd_all.tar.gzfile, handle the stratified sampling logic in Google Colab, and perform batch translation of local languages. Also utilized to refine the Random Forest TimeSeriesSplit validation strategy.
- **Human-Created**: All analysis logic, interpretation of visualizations, validation, and final strategic conclusions.

## Key Findings

### Heat (tasmax) and Seasonality Outperform Rainfall as the Primary Drivers of 'Pest & Disease' Questions
Feature Importance analysis consistently identified Maximum Temperature (tasmax) and Month (month_num) as the strongest predictors of pest question volume, significantly outperforming rainfall and rainfall anomalies.

Biological Insight: While rainfall creates the potential for pests, higher temperatures tend to accelerate insect breeding cycles, increasing the instances of pest presence.

Implications: Producers Direct should prioritize "Warm + Wet" alerts. A combination of seasonal rain and high heat forecasts would be important to implement for pest advisory campaigns.

### The Limits of National-Level Prediction
The predictive model yielded a negative R^2 score (-5.35) for question volume.

This metric confirms that Country-level weather is too broad to predict localized spikes. A difference in weather in different regions average out to "Normal" in the dataset, which washes out the signal.

Despite the poor volume prediction, the model predictions follow the general trend of the actual data, confirming that farming calendars (month_num) are the baseline driver of farmers' questions.

## Visualizations

###  Actual vs. Predicted Question Volume (The "Trend" Insight)
http://localhost:8888/lab/tree/Challenge%201%20_Weather%20Patterns/allisonsibrian/predictions_and_actual.png

**Interpretation**: The Predicted Line (Green) tends to rise and fall in sync with the Actual Line (Black). This proves the model successfully learned the seasonal cycle of farmer needs. Due to the lack of regional data, the model lacks the granular location data to predict how many questions will be asked during a specific instance. 

### Feature Importance
http://localhost:8888/lab/tree/Challenge%201%20_Weather%20Patterns/allisonsibrian/feature_importances.png

**Interpretation**: Heat and Seasonality dominate the model, validating the recommendation to shift content strategy toward temperature-based alerts and seasonal calendars.

## Limitations and Challenges

### Data Limitations
- Weather and Questions were averaged at the Country Level. This is the primary reason for the low predictive accuracy (R^2).
- Training on only 792 aggregated data points (derived from the 0.5% sample and aggregating) limited the model's ability to learn complex non-linear patterns.

### Technical Challenges
- Computational constraints: Translating 21.5 million rows was not possible due to computational constraints. I used a 0.5% sampling strategy per language group as it was a necessary trade-off between translation quality and processing time.
- Translation accuracy issues: Some translations resulted in hallucinations (e.g., "Attorney General"). This required implementing keyword filtering to obtain usable data. 

## Next Steps and Recommendations

### For Further Analysis
1.  If future datasets include User Location (Region/County), analysis could be stronger with these new geospatial points.
2.  Specifying topics: Could specify topics (i.e. 'Crops') as different crops have different weather sensitivities.

### For Producers Direct
1. Can deploy and utilize the Random Forest model to flag high-risk months.
2. Moving towards a seasonal farmer calendar 'alert' approach would be helpful, which was validated by the month_num signal.

## Contact and Collaboration

**Author**: Allison Sibrian
**GitHub**: @allisonsibrian

**Collaboration Welcome**: 
- Open to feedback and suggestions
- Happy to collaborate on related analyses
- Available to answer questions about this approach

## Acknowledgments
- Thanks to Bashir Alsuty for the de-duplicated data split by language files, and Steven Yan for the Comet Scores on translation models for Swahili, Luganda, and Runyankole, as they were used in my pre-processing stage.
---

**Last Updated**: November 27th, 2025
