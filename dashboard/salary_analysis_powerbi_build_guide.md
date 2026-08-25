# Salary Analysis — Power BI Build Guide

This is the full recipe to turn `salary_data_cleaned.csv` into `salary_analysis.pbix` in Power BI Desktop. It mirrors the EDA you already did in `eda.ipynb` (distribution, gender, education, experience, top job titles, correlation).

Total build time: ~20–30 minutes.

---

## 0. Prerequisites

- Power BI Desktop (free, Windows only). Download: https://powerbi.microsoft.com/desktop/
- `salary_data_cleaned.csv` saved somewhere in your project folder, e.g. `data/salary_data_cleaned.csv`
- Confirmed columns: `Age`, `Gender`, `Education Level`, `Job Title`, `Years of Experience`, `Salary` (324 clean rows, no nulls, no duplicates)

---

## 1. Import the data

1. Open Power BI Desktop → **Get Data** → **Text/CSV**
2. Select `salary_data_cleaned.csv`
3. Click **Transform Data** (not "Load") — this opens Power Query Editor

---

## 2. Power Query (M) — cleaning & feature engineering

Even though your CSV is already clean, add these steps in Power Query so the pipeline is reproducible and so you get the grouping columns your charts need. In Power Query Editor, use **Home → Advanced Editor** and paste this (adjust the file path on line 3):

```m
let
    Source = Csv.Document(File.Contents("C:\Path\To\salary_data_cleaned.csv"),
        [Delimiter=",", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    ChangedTypes = Table.TransformColumnTypes(PromotedHeaders,{
        {"Age", Int64.Type},
        {"Gender", type text},
        {"Education Level", type text},
        {"Job Title", type text},
        {"Years of Experience", Int64.Type},
        {"Salary", Int64.Type}
    }),
    TrimmedText = Table.TransformColumns(ChangedTypes, {
        {"Gender", Text.Trim, type text},
        {"Education Level", Text.Trim, type text},
        {"Job Title", Text.Trim, type text}
    }),
    RemovedEmptyRows = Table.SelectRows(ChangedTypes, each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
    RemovedDuplicates = Table.Distinct(TrimmedText),

    // --- Feature engineering: bands used by the report visuals ---
    AddedAgeBand = Table.AddColumn(RemovedDuplicates, "Age Band", each
        if [Age] < 25 then "Under 25"
        else if [Age] <= 34 then "25–34"
        else if [Age] <= 44 then "35–44"
        else if [Age] <= 54 then "45–54"
        else "55+"),

    AddedExperienceBand = Table.AddColumn(AddedAgeBand, "Experience Band", each
        if [Years of Experience] < 2 then "0–1 yrs (Entry)"
        else if [Years of Experience] <= 5 then "2–5 yrs (Junior)"
        else if [Years of Experience] <= 10 then "6–10 yrs (Mid)"
        else if [Years of Experience] <= 15 then "11–15 yrs (Senior)"
        else "16+ yrs (Expert)"),

    AddedSalaryBand = Table.AddColumn(AddedExperienceBand, "Salary Band", each
        if [Salary] < 50000 then "< 50K"
        else if [Salary] < 100000 then "50K–100K"
        else if [Salary] < 150000 then "100K–150K"
        else if [Salary] < 200000 then "150K–200K"
        else "200K+"),

    ChangedFinalTypes = Table.TransformColumnTypes(AddedSalaryBand,{
        {"Age Band", type text}, {"Experience Band", type text}, {"Salary Band", type text}
    })
in
    ChangedFinalTypes
```

Click **Close & Apply**.

> Note: this table is your fact table. It will be referred to as **Salary** in the DAX below (Power BI names the table after the query — rename the query to `Salary` in the Queries pane if it isn't already).

---

## 3. Build a Job Title dimension (for the Top-15 chart)

Your notebook filtered job titles to those with `count >= 2` before ranking by mean salary. Rather than filtering the fact table, do this with a DAX measure (Step 5) so slicers still work — no extra table needed here.

---

## 4. Data model

This is a single flat table, so no relationships are needed. Optional: if you want a proper star schema for practice, create a `Dim_JobTitle` table (Modeling → New Table):

```dax
Dim_JobTitle = DISTINCT('Salary'[Job Title])
```

Then relate `Dim_JobTitle[Job Title]` (one) → `Salary[Job Title]` (many). Not required, but good practice to show in a portfolio project.

---

## 5. DAX measures

Create a new **Measures table** first (Modeling → New Table → name it `_Measures`, just type `_Measures = {1}` then delete the column from Fields view — this keeps measures organized). Add all measures below to `_Measures`.

### Core KPIs

```dax
Total Employees = COUNTROWS('Salary')

Average Salary = AVERAGE('Salary'[Salary])

Median Salary = MEDIAN('Salary'[Salary])

Min Salary = MIN('Salary'[Salary])

Max Salary = MAX('Salary'[Salary])

Salary StdDev = STDEV.P('Salary'[Salary])

Average Age = AVERAGE('Salary'[Age])

Average Experience (Yrs) = AVERAGE('Salary'[Years of Experience])
```

### Mean vs Median gap (from your notebook's step 22)

```dax
Mean-Median Gap = [Average Salary] - [Median Salary]

Mean-Median Gap % = DIVIDE([Mean-Median Gap], [Median Salary])
```

### IQR outlier detection (replicates notebook steps 20–21)

```dax
Salary Q1 =
PERCENTILEX.INC(ALLSELECTED('Salary'), 'Salary'[Salary], 0.25)

Salary Q3 =
PERCENTILEX.INC(ALLSELECTED('Salary'), 'Salary'[Salary], 0.75)

Salary IQR = [Salary Q3] - [Salary Q1]

Salary Lower Bound = [Salary Q1] - (1.5 * [Salary IQR])

Salary Upper Bound = [Salary Q3] + (1.5 * [Salary IQR])

Is Salary Outlier =
VAR CurrentSalary = SELECTEDVALUE('Salary'[Salary])
RETURN
    IF(
        CurrentSalary < [Salary Lower Bound] || CurrentSalary > [Salary Upper Bound],
        "Outlier", "Normal"
    )

Outlier Count =
COUNTROWS(
    FILTER(
        'Salary',
        'Salary'[Salary] < [Salary Lower Bound] || 'Salary'[Salary] > [Salary Upper Bound]
    )
)
```

### Gender pay gap (notebook step 27)

```dax
Male Avg Salary =
CALCULATE([Average Salary], 'Salary'[Gender] = "Male")

Female Avg Salary =
CALCULATE([Average Salary], 'Salary'[Gender] = "Female")

Gender Pay Gap =
[Male Avg Salary] - [Female Avg Salary]

Gender Pay Gap % =
DIVIDE([Gender Pay Gap], [Male Avg Salary])
```

### Education level analysis (notebook step 28)

```dax
Avg Salary by Education =
CALCULATE([Average Salary], ALLEXCEPT('Salary', 'Salary'[Education Level]))

Education Salary Rank =
RANKX(ALL('Salary'[Education Level]), CALCULATE([Average Salary]), , DESC)
```

### Correlation (notebook step 32 — Age/Experience/Salary)

Power BI has no native CORREL function, so this uses the Pearson formula directly:

```dax
Corr Experience Salary =
VAR N = COUNTROWS('Salary')
VAR SumX = SUMX('Salary', 'Salary'[Years of Experience])
VAR SumY = SUMX('Salary', 'Salary'[Salary])
VAR SumXY = SUMX('Salary', 'Salary'[Years of Experience] * 'Salary'[Salary])
VAR SumX2 = SUMX('Salary', 'Salary'[Years of Experience]^2)
VAR SumY2 = SUMX('Salary', 'Salary'[Salary]^2)
VAR Numerator = (N * SumXY) - (SumX * SumY)
VAR Denominator = SQRT( ((N * SumX2) - SumX^2) * ((N * SumY2) - SumY^2) )
RETURN DIVIDE(Numerator, Denominator)

Corr Age Salary =
VAR N = COUNTROWS('Salary')
VAR SumX = SUMX('Salary', 'Salary'[Age])
VAR SumY = SUMX('Salary', 'Salary'[Salary])
VAR SumXY = SUMX('Salary', 'Salary'[Age] * 'Salary'[Salary])
VAR SumX2 = SUMX('Salary', 'Salary'[Age]^2)
VAR SumY2 = SUMX('Salary', 'Salary'[Salary]^2)
VAR Numerator = (N * SumXY) - (SumX * SumY)
VAR Denominator = SQRT( ((N * SumX2) - SumX^2) * ((N * SumY2) - SumY^2) )
RETURN DIVIDE(Numerator, Denominator)
```

### Top job titles (notebook step 31 — filtered to count ≥ 2)

```dax
Job Title Count = COUNTROWS('Salary')

Avg Salary by Job (Qualified) =
VAR JobCount = [Job Title Count]
RETURN IF(JobCount >= 2, [Average Salary], BLANK())
```
Use this measure in the Top-15 bar chart instead of `Average Salary` — job titles with fewer than 2 records will simply not plot.

---

## 6. Report pages (matches your EDA notebook 1:1)

**Page 1 — Overview**
- Card visuals: Total Employees, Average Salary, Median Salary, Mean-Median Gap %
- Histogram (use a "Salary Band" bar chart, or the Analytics pane's histogram if using a visual like the "Box and Whisker" custom visual from AppSource) of `Salary`
- Box-and-whisker plot of `Salary` (install the free "Box and Whisker Chart" visual from AppSource — native Power BI has no boxplot)

**Page 2 — Gender Analysis**
- Clustered column: `Average Salary` by `Gender`
- Cards: Male Avg Salary, Female Avg Salary, Gender Pay Gap %
- Box-and-whisker: `Salary` by `Gender`

**Page 3 — Education Analysis**
- Clustered column: `Average Salary` by `Education Level`, sorted descending
- Box-and-whisker: `Salary` by `Education Level`
- Table: Education Level, Job Title Count, Avg Salary, Median Salary

**Page 4 — Experience & Age vs Salary**
- Scatter chart: X = `Years of Experience`, Y = `Salary`, Legend = `Gender`
- Scatter chart: X = `Age`, Y = `Salary`, Legend = `Gender`
- Two cards: `Corr Experience Salary`, `Corr Age Salary`

**Page 5 — Top Job Titles**
- Horizontal bar chart: `Job Title` (Y) vs `Avg Salary by Job (Qualified)` (X), Top N filter = 15, sorted descending

**Page 6 — Correlation Matrix**
- Table or matrix visual with Age, Years of Experience, Salary as both rows/columns showing the three correlation measures (or use the "Correlation Plot" custom visual from AppSource for a heatmap like your seaborn one)

Add slicers for `Gender`, `Education Level`, `Age Band`, and `Experience Band` on every page (sync slicers via **View → Sync Slicers**).

---

## 7. Save as .pbix

**File → Save As** → `salary_analysis.pbix`. Put it in your project's `powerbi/` or `dashboards/` folder so it sits alongside `eda.ipynb` and the CSV in your VS Code repo.

Since `.pbix` is a binary format, VS Code will show it as a file you can open with Power BI Desktop but not edit/preview directly — that's expected. If you want something VS-Code-native to preview too, consider exporting each page as a PNG/PDF (File → Export → PDF) into a `screenshots/` folder for your README.

---

## 8. Suggested README snippet for your repo

```markdown
## Dashboard
Interactive Power BI dashboard built on the cleaned dataset (`data/salary_data_cleaned.csv`).
- 6 report pages: Overview, Gender Analysis, Education Analysis, Experience/Age vs Salary, Top Job Titles, Correlation Matrix
- Custom DAX measures for IQR outlier detection, Pearson correlation, and gender pay gap
- File: `powerbi/salary_analysis.pbix` (requires Power BI Desktop to open)
```
