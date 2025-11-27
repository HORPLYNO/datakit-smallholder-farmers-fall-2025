# Precious Enahoro - Beyond Farming - Financial Inclusion and Livelihood Analysis

## Overview
This project explores how smallholder farmers discuss financial topics such as market prices, credit access, savings, and other non-farming livelihood concerns, to better understand their economic realities, challenges and opportunities for inclusion through financial tools, information to manage risk and investments in productivity. This analysis would inform Producer Direct's support for farmer entrepreneurship, market access, and rural financial systems.

## Research Questions
- Question 1: What share of farmer questions relate to financial topics?
- Question 2: How do financial questions vary across seasons and regions?
- Question 3: How do farmers express financial challenges and opportunities?

## Key Findings

### Finding 1: [Title]
Description of the finding, supported by data and visualizations.

**Implications for Producers Direct:**
- How this finding can be used
- What actions it suggests

### Finding 2: [Title]
Description of the finding, supported by data and visualizations.

**Implications for Producers Direct:**
- How this finding can be used
- What actions it suggests

### Finding 3: [Title]
Description of the finding, supported by data and visualizations.

**Implications for Producers Direct:**
- How this finding can be used
- What actions it suggests

## Visualizations

### [Visualization 1 Title]
![Visualization 1](visualizations/viz1.png)

**Interpretation**: What this visualization shows and why it matters.

### [Visualization 2 Title]
![Visualization 2](visualizations/viz2.png)

**Interpretation**: What this visualization shows and why it matters.

## Recommendations
### For Producers Direct
1. **Action 1**: Specific recommendation for the organization
2. **Action 2**: How to use these insights
3. **Action 3**: What additional data or resources would help

## Next Steps 
### For Further Analysis
1. **Recommendation 1**: What could be explored next
2. **Recommendation 2**: How to deepen this analysis
3. **Recommendation 3**: Related questions to investigate

## Limitations and Challenges

### Data Limitations
- Missing data issues
- Data quality concerns
- Sample size or coverage limitations

### Methodological Limitations
- Assumptions made
- Simplifications required
- Alternative approaches not explored

### Technical Challenges
- Computational constraints
- Translation accuracy issues
- Other technical hurdles

## Methodology
### Data Source
- Producers Direct English Dataset

### Approach
**Step 1**: Data loading, cleaning, and preprocessing
   - Processed data efficiently using DuckDB for large-file handling.
   - Cleaned, normalized, and deduplicated raw question data and standardized country codes.  Data was deduplicated to remove multiple responses to a particular question, since the analysis focused only on questions. This reduced the final dataset to ~3M rows.
   - Built classification logic for financial categories and refined sub-themes for each category.
   - Generated binary financial flags, matched keywords, topic groupings, and normalized text fields by implementing regex-based topic extraction.
  
 **Step 2**: Analysis and statistics
   - Conducted chi-square tests to measure significant differences across countries and categories.
   - Performed time series analysis to detect seasonal spikes in financial behavior.
   - Compared product-level economic concerns (e.g., maize vs. poultry vs. tomatoes).
   - Evaluated cross-country patterns in credit needs, subsidies, savings culture, and hardship.
     
**Step 3**: Visualization, report, and interpretation
   - Designed Tableau dashboards to explore and visualize monthly trends, category flows, and country differences [Tableau Packaged Workbook Uploaded]
   - Produced summary insights focused on farmers’ real-world financial pain points.
   - Wrote interpretive narratives explaining behavioral patterns and regional variations.

### Tools and Technologies
- **Programming Language**: SQL
- **GenAI Tools Used**: ChatGPT
- **Other Tools**: Tableau, Excel.

## Use of Generative AI
### AI-Assisted vs. Human-Created
- **AI-Assisted**:
    - Generating SQL CASE WHEN blocks and regex patterns.
    - Debugging SQL/regex errors and restructuring complex logic.
    - Creating aggregation query templates and cleaning functions.
    - Providing statistical test outputs and helping phrase insight summaries.
    - Exploratory thought partner on financial taxonomy and figuring out edge cases.

- **Human-Created**
    - Designed the financial taxonomy and defined all category logic.
    - Cleaned, prepared, and deduplicated the raw farmer-question dataset.
    - Built and validated the final classification rules.
    - Created aggregated tables, trends, and chi-square analyses.
    - Interpreted patterns (seasonality, country differences, product-level insights).
    - Designed Tableau visuals and wrote the final analytical narrative.
    * All AI-generated SQL code and initial insight summaries were reviewed and tested for accuracy.*

## Files in This Contribution

```
your_name_analysis/
├── README.md (this file)
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_data_cleaning.ipynb
│   └── 03_analysis.ipynb
├── scripts/
│   ├── data_loader.py
│   ├── preprocessing.py
│   └── visualization.py
├── visualizations/
│   ├── viz1.png
│   ├── viz2.png
│   └── viz3.png
├── results/
│   ├── summary_statistics.csv
│   └── findings.md
└── data/ (if applicable - only small derived datasets)
    └── processed_sample.csv
```

## Dependencies

SQL code ran using DuckDB driver in DBeaver.
```

### Cleaning the Data and Running the Analysis --to be updated
# Open and run scripts in order:
# 1. 01_data_exploration.ipynb
# 2. 02_data_cleaning.ipynb
# 3. 03_analysis.ipynb
```

## Contact and Collaboration
**Author**: Precious Enahoro
**GitHub**: @PreciousEnahoro
**Linkedin**: (https://www.linkedin.com/in/precious-enahoro/)

**Collaboration Welcome**: 
- Open to feedback and suggestions
- Happy to collaborate on related analyses
- Available to answer questions about this approach

## Acknowledgments
- Inspired by @TrevorW's sharing of how he started to think about the financial taxonomies on Slack!
---

**Last Updated**: 11/26/2025
**Status**: In Progress

