# README

## Overview

This repository contains the R Markdown report and supporting code for Challenge 2: Seasonality of Farmer Questions. The analysis explores how farmer questions vary across months, countries, and topics, with a particular focus on Kenya and Uganda. By aligning question trends with cropping calendars, the report highlights seasonal peaks in farmer needs (e.g., pest control during planting, market access after harvest).

## Contents

Challenge2_Report.Rmd: Detailed RMarkdown report with code chunks, narrative, and visualisations.

Challenge2_Report.pdf: Compiled stakeholder-ready report.

Challenge2_code.R: Code used for data analysis before creating the final report.

## Key Insights

-   Farmer engagement is seasonal, peaking in planting and harvest months.

-   Kenya: Two peaks (long rains Mar–May, short rains Oct–Dec).

-   Uganda: Two cropping seasons (Season A Mar–May, Season B Sep–Nov).

-   Topics:

    -   Planting → seed varieties, pest control, soil fertility.

    -   Harvest → storage, pricing, market access.

    -   Livestock/poultry → steady year‑round.

-   Implication: Support services (advice, market info, pest alerts) should be timed to cropping calendars.

## Use of AI

AI was used to improve aesthetics, structure the R Markdown report, refine the narrative, and ensure code chunks were embedded with clear explanations. This helped transform raw analysis into a stakeholder‑friendly document that combines reproducibility with actionable insights.

## How to run

1.  Open `Challenge2_Report.Rmd` in RStudio.
2.  Ensure required packages are installed. Libraries are mentioned in the `Challenge2_Report.Rmd`.
3.  Load the data and save it in `agridata.rds`.
4.  Knit `Challenge2_Report.Rmd` as HTML/PDF.
