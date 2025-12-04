# Omar Bensatal — Challenge 1 Weather × Topic Analysis

## Overview
This analysis extends the Challenge 1 Producers Direct exploration by linking farmer question traffic to weather patterns across Kenya, Tanzania, and Uganda. The goal is to understand how climate regimes influence question volume/topic mix so that Producers Direct can better anticipate advice demand and prioritize agronomic content for smallholder farmers.

## Research Questions
- **RQ1:** How clean and complete is the 20.3 M record event feed (duplicates, missing topics, language coverage)?
- **RQ2:** Do observed weather regimes (dry/soaked weeks, cool/hot spells) shift overall question volume or topic shares in Kenya and Tanzania?
- **RQ3:** Can monthly national climate metrics explain Uganda topic leaders, and how do these results compare to weekly forecasts built on Kenya/Tanzania merges?

## Methodology

### Data Sources
- `datakind_dataset.csv` — primary Q&A event feed (questions, responses, metadata, timestamps, language, topics).
- Daily merged station weather tables for Kenya and Tanzania (precipitation, maximum/minimum temperature, rolling aggregates stored under `WEATHER_DIR`).
- Uganda national climate Excel sheets (`CDD`, `CWD`, and `TAS` monthly statistics for 1950‑2023) delivered via `UGANDA_SHEETS` mapping.
- All merges, filtering, and feature engineering steps are logged through `process_log.md` per repo policy.

### Approach
1. **Staged EDA (Sections 2.1‑2.16):** Schema inspection, missing-value audits, duplicate surfacing (5.45 M duplicates), language/demographic distributions, datetime parsing, temporal frequency plots, unique-ID counts, power-user extraction, and token statistics.
2. **Weather integration (Sections 19‑21):** Load raw NOAA-style station feeds, aggregate to daily means, compute rolling precipitation/temperature windows, and join features onto Kenya/Tanzania question records via date and location keys.
3. **Regime analysis (Section 22):** Derive dry/typical/soaked precipitation regimes plus cool/warm/hot temperature regimes, then compare topic shares, bar charts, and textual summaries.
4. **Forecast experiments (Section 23):** Build a weekly “topic leader” classifier using weather-only features (logistic regression benchmark) to test near-term predictability.
5. **Uganda workflow (Section 24):** Melt monthly CDD/CWD/TAS Excel files, align with Uganda question months, create regime summaries/visualizations, and train weather-only models on monthly aggregates.
6. **Synthesis (Section 25):** Summarize coverage, insights, limitations, and next steps for Producers Direct stakeholders.

### Tools and Technologies
- **Language & Environment:** Python 3.11 via Jupyter Notebook.
- **Key Libraries:** `pandas`, `numpy`, `matplotlib`, `seaborn`, `scikit-learn`, `pathlib`.
- **GenAI Tools Used:** GitHub Copilot (GPT-5.1-Codex Preview) to draft markdown summaries, restructure section headings, and scaffold plotting/model-comparison boilerplate.
- **Other Assets:** Repo-level logging helpers (`logs/log_writer.py`) for process/data-change tracking.

## Use of Generative AI

### Tools Used
- **GitHub Copilot (GPT-5.1-Codex Preview):** Assisted in drafting markdown summaries, renaming notebook sections, and boilerplate for visualization/model cells.

### Human Review Process
- Every AI-suggested cell was reviewed, edited, and executed inside `challenge_1_omar_bensatal_final.ipynb` to ensure correctness.
- Outputs (tables/plots) were validated against source data. Any warnings (e.g., timezone conversions, sklearn precision issues) were investigated and resolved or documented.

### AI-Assisted vs. Human-Created
- **AI-Assisted:** Markdown restructuring, plotting scaffolds for regime charts, initial classifier evaluation blocks.
- **Human-Created:** Data cleaning logic, weather merging, Uganda ingestion pipeline, interpretation of findings, conclusions, and all README content.

## Key Findings

### Finding 1: Data coverage is large but noisy
- 20,304,843 timestamped records exist, yet 5,447,943 are exact duplicates (2,978,928 rows would be dropped when keeping first occurrence).
- `question_topic` is missing for 3.54 M rows and demographic fields (gender, DOB) are >95 % NULL.
- **Implication:** Upstream deduplication and topic backfilling are prerequisites before deploying behavioral models.

### Finding 2: Weather regimes subtly shift demand
- Dry and soaked weeks hold ~1.26 M and ~1.35 M questions respectively; cool vs. hot spells carry 1.30 M vs. 1.41 M questions.
- Topic share deltas reach +2.94 pp for chicken and +1.95 pp for maize between precipitation regimes.
- Weather-only Gradient Boosting improves accuracy from a 0.264 baseline to 0.333 (macro-F1 0.266). Random Forest provides the best balance (macro-F1 0.311) albeit slightly lower accuracy (0.318).
- **Implication:** Even simple weather features help triage incoming demand (e.g., emphasize poultry support during soaked weeks) but richer features are needed for precise routing.

### Finding 3: Uganda monthly climate lens is promising but coarse
- 888 monthly CDD/CWD/TAS rows map 100 % of the 6.31 M Uganda questions, enabling national-level regime narratives.
- Gradient Boosting reaches 0.482 accuracy (macro-F1 0.236) vs. a 0.462 majority baseline; Random Forest sacrifices accuracy (0.354) for stronger minority-topic F1 (0.303, `other` topic 0.51).
- **Implication:** Monthly climate indicators provide signal, yet adding farmer text, geography, and lagged shocks is required to exceed 0.6 accuracy and support operational decisions.

### Finding 4: Weekly leader forecast is not production-ready
- Weather-only weekly classifiers scored 0.639 accuracy against a 0.705 baseline, indicating insufficient data per week/topic.
- **Implication:** Collect longer histories or incorporate behavioral/text features before deploying leaderboards or alerts.

## Visualizations

### Kenya & Tanzania regime sensitivity
Visuals in Section 22 include precipitation/temperature regime bar charts and heatmaps showing top topics per regime. They highlight livestock topics spiking during soaked/hot spells.

### Uganda climate vs. question volume
Section 24.1 overlays monthly CDD/CWD/TAS with Uganda question counts, illustrating how farmer engagement tracks prolonged dryspells or temperature spikes.

### Uganda regime/topic grids
Section 24.2.1 adds side-by-side bar charts and heatmaps comparing dryspell/wetspell/temperature regimes to topic shares, enabling narrative storytelling (e.g., goat questions peak in wetspells).

## Limitations and Challenges

### Data Limitations
- 5.45 M duplicate rows; 3.54 M records lack `question_topic` labels (this to be reviewed in more detail).
- Gender/DOB columns are largely empty; timezone conversions emit warnings due to mixed offsets.
- Weather coverage exists only for Kenya/Tanzania daily grids and Uganda national monthly aggregates (no humidity, soil moisture, or pest indices).
- `question_content` and `response_content` span multiple languages; translation or language-aware tokenization is required before richer NLP or cross-country comparisons (for better results).

### Methodological Limitations
- Topic imbalance leads to undefined precision in minority classes; models rely solely on weather, omitting text/user behaviors.
- Uganda analysis aggregates to national monthly levels, masking sub-regional variability.
- topic definitions may be noisy or inconsistent; unsupervised topic modeling was not applied here.

### Technical Challenges
- Large files required chunked operations and careful memory management for duplicate checks and merges.
- Sklearn warnings (e.g., undefined precision) required zero-division handling and interpretation.

## Next Steps and Recommendations

### For Further Analysis
1. **Deduplicate upstream:** Implement an ETL step that removes the 2.98 M redundant rows and logs the change in `data_change_log.md`.
2. **Backfill topics:** Use multilingual NLP or clustering to assign topics to the 3.54 M unlabeled records, then validate with agronomists.
3. **Enhance features:** Add humidity, drought indices, soil moisture, and lagged weather deltas; incorporate farmer text embeddings and geography.

### For Producers Direct
1. **Actionable monitoring:** Use regime share dashboards to anticipate poultry support demand during soaked periods and adjust messaging.
2. **Targeted outreach:** Leverage country-level topic skews (Kenya cattle/chicken, Uganda maize/tomato, Tanzania maize/poultry) to localize advisory content.
3. **Data partnerships:** Secure higher-resolution Ugandan weather feeds (regional/monthly) to improve predictive accuracy and enable district-level insights.

## Files in This Contribution
```
analysis/
├── README.md                # This file
├── challenge_1_omar_bensatal_final.ipynb  # Weather-aware EDA & modeling notebook
├── challenge_1/top_power_users.csv    # Export from Section 2.13
└── data_change_log.md, process_log.md # Repository-wide logs (updated via notebook) 
```

## How to Run This Analysis

### Prerequisites
```bash
pip install pandas numpy matplotlib seaborn scikit-learn jupyter
```

### Running the Notebook
```bash
# From repo root
jupyter notebook challenge_1_omar_bensatal_final.ipynb
```
Run cells sequentially; sections are modular so Uganda analyses (24.x) can be re-run independently once earlier ingestions complete. Append process/data-change entries via `logs/log_writer.py` whenever you alter source data.

## References and Resources
- Producers Direct Challenge 1 dataset (`datakind_dataset.csv`).
- NOAA Global Historical Climatology Network station files (daily precip/temperature) curated for Kenya/Tanzania.
- Uganda national climate summaries (CDD/CWD/TAS) provided with the event package.
- you can find the data in: https://drive.google.com/drive/folders/1aofZhMytKIUEfq-M4GqrjHyVZqHpmCSm?usp=drive_link
- Python libraries documented at https://pandas.pydata.org/, https://scikit-learn.org/.

## Contact and Collaboration
- **Author:** Omar Bensatal (DataKind Challenge 1 contributor)
- Collaboration welcome—open an issue or reach out via the event workspace with questions about weather merges or to contribute new features.

## Acknowledgments
- Thanks to the DataKind/DataKit organizers for supplying weather feeds and logging templates.
- Built upon prior Challenge 1 groundwork (`challenge_1_omar_bensatal.ipynb`) and repository logging infrastructure.

---
**Last Updated:** 2025-12-04
**Status:** Done — ready for review by Producers Direct and DataKind team.
