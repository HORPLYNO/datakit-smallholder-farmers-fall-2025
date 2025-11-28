# DataKind Challenge 2: Seasonality Analysis

### Author

Kaushal Bhingaradia

### Objective

This project analyzes the seasonality of questions asked by farmers in the Producers Direct network. The goal is to understand temporal patterns in farmer queries, identify key topics, and visualize how these topics fluctuate throughout the year. This insight helps in anticipating farmer needs and providing timely support.

### Approach

1.  **Data Understanding & Sampling** – Explored the structure of questions, responses, users, and locations. **Note:** Due to the large file size of the original dataset, a small sample was used for this analysis to ensure faster processing and iteration.
2.  **Data Preprocessing** – Converted timestamps to datetime objects and extracted temporal features (Month, Year, Day of Year).
2.  **Seasonality Analysis** – Analyzed monthly trends in question volume to identify peak periods of engagement.
3.  **Circular Seasonality Visualization** – Used polar plots to visualize the cyclical nature of question volume over a 12-month cycle.
4.  **Time Series Decomposition** – Decomposed the time series data into **Trend**, **Seasonality**, and **Residual** components to isolate underlying patterns from noise.
5.  **Topic Modeling (LDA)** – Applied **Latent Dirichlet Allocation (LDA)** to identify the most common topics within the questions (e.g., specific crops, livestock, diseases).
6.  **Topic Seasonality** – Analyzed the monthly distribution of specific topics to understand when farmers are asking about particular subjects (e.g., planting vs. harvesting seasons).

### Key Insights

-   **Seasonal Volume:** The highest volume of questions occurs in **January and February (Winter)**, with a secondary peak in **June**. The lowest volume is observed in **May**.
-   **Geographic Distribution:** The majority of the questions originate from **Kenya**, with the remainder from **Uganda**.
-   **Circular Seasonality:** The "Winter" months (Jan/Feb) exhibit the strongest circular seasonality in question volume.
-   **Top Winter Topics:** In January and February, the top 10 topics include **Chicken, Bean, Cattle, Rabbit, Poultry, and Pig**.
-   **Farming Calendar Inference:**
    -   Scores for **Planting**, **Harvesting**, and **Pests** drop to their lowest levels in **September and October**.
    -   These scores rise again starting in **December**, staying high through **January and February** before dropping down towards the fall.
-   **Time Series Analysis:** Confirms that the winter period consistently has the most questions.
-   **Key Topics:** LDA modeling successfully identified major themes in the data, such as specific crops (e.g., Maize, Beans, Coffee) and livestock management.
-   **Topic-Specific Timing:** Different topics show unique seasonal patterns, allowing for targeted content delivery based on the time of year.

### Visualizations

The analysis includes several key visualizations:
-   **Monthly Question Volume:** Bar charts showing the total number of questions per month.
-   **Circular Seasonality Plot:** A polar plot highlighting the cyclical distribution of questions.
-   **Time Series Decomposition:** Graphs showing the Observed, Trend, Seasonal, and Residual components.
-   **Top Words per Topic:** Bar charts (with enhanced coloring) displaying the most frequent words associated with each LDA topic.
-   **Topic Seasonality Trends:** Line charts tracking the prevalence of specific topics over the months.

### Files

-   `challenge_2_seasonality.ipynb` – Full Jupyter Notebook containing the code and analysis.
-   `README.md` – Project summary and documentation.

### Use of Generative AI

This analysis was completed with **human oversight and GenAI support**:

-   **Tool used:** Gemini
-   **Purpose:** Assisted with organizing the notebook, suggesting syntax, and writing code and sentence snippets for visualization and analysis.
-   **Human review:** All code, outputs, and insights were manually validated for correctness and relevance.

### Outcome

This analysis provides a data-driven understanding of the seasonal dynamics of farmer inquiries. By identifying *when* farmers ask about *what*, Producers Direct can better allocate resources, prepare relevant content in advance, and proactively support farmers throughout the agricultural calendar.
