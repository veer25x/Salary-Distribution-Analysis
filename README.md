# Salary-Distribution-Analysis
End-to-end salary data analysis project using Python, SQL, and Power BI to explore salary distribution, employee demographics, education, job roles, and experience-based compensation patterns.

# Salary Distribution & Compensation Analysis

An end-to-end Data Analyst project analyzing employee salary patterns based on age, gender, education level, job title, and years of experience.

The project demonstrates a complete data analytics workflow using Python, SQL, and Power BI — from data cleaning and exploratory analysis to business insights and interactive visualization.

---

## Project Overview

Understanding salary distribution is important for compensation benchmarking, workforce planning, and identifying relationships between employee characteristics and compensation.

This project analyzes a salary dataset containing employee-level information such as:

- Age
- Gender
- Education Level
- Job Title
- Years of Experience
- Salary

The analysis focuses on understanding salary distribution and exploring how compensation varies across employee characteristics.

---

## Project Objectives

The main objectives of this project are:

- Clean and validate the salary dataset
- Identify missing and duplicate records
- Analyze salary distribution
- Understand salary differences across gender
- Analyze salary differences across education levels
- Explore job-title salary patterns
- Examine the relationship between experience and salary
- Identify salary ranges and high-paying roles
- Perform analytical queries using SQL
- Build an interactive Power BI dashboard
- Generate business-oriented insights from the analysis

---

## Dataset

The original dataset contains:

- **375 records**
- **6 columns**

### Dataset Columns

| Column | Description |
|---|---|
| Age | Age of the employee |
| Gender | Gender of the employee |
| Education Level | Highest education level |
| Job Title | Employee's job role |
| Years of Experience | Total years of professional experience |
| Salary | Employee salary |

The dataset contains three education levels:

- Bachelor's
- Master's
- PhD

There are **174 unique job titles** in the cleaned dataset.

---

## Data Cleaning

The data-cleaning process was performed using Python and Pandas.

### Cleaning steps

1. Loaded the raw CSV dataset
2. Inspected dataset structure and data types
3. Checked missing values
4. Removed completely empty rows
5. Checked duplicate records
6. Removed exact duplicate records
7. Cleaned text columns using `.str.strip()`
8. Validated categorical values
9. Checked numerical values
10. Checked for invalid age values
11. Checked for negative experience values
12. Checked for invalid salary values
13. Checked whether experience exceeded age
14. Performed salary outlier detection using the IQR method

### Cleaning Results

| Metric | Result |
|---|---:|
| Original records | 375 |
| Completely empty records removed | 2 |
| Records before duplicate removal | 373 |
| Exact duplicate records removed | 49 |
| Final records | 324 |
| Final columns | 6 |
| Remaining missing values | 0 |
| Salary IQR outliers | 0 |

After cleaning, the final analytical dataset contains **324 records and 6 columns**. 

---

## Exploratory Data Analysis

The exploratory analysis focuses on several important salary-related questions.

### Salary Distribution

The salary distribution was analyzed using:

- Histogram
- KDE curve
- Boxplot
- Mean and median comparison

The analysis found:

- Mean salary: **99,985.65**
- Median salary: **95,000**
- Q1: **55,000**
- Q3: **140,000**
- IQR: **85,000**
- IQR upper boundary: **267,500**
- IQR-based salary outliers: **0**

The mean being slightly higher than the median indicates that higher salaries influence the overall average.

---

### Gender Analysis

Salary distribution is analyzed across:

- Male employees
- Female employees

The analysis compares:

- Employee count
- Average salary
- Median salary
- Salary distribution

---

### Education Analysis

Salary patterns are analyzed across:

- Bachelor's
- Master's
- PhD

The objective is to understand whether compensation differs across education levels.

---

### Job Title Analysis

The dataset contains **174 unique job titles**.

Instead of displaying every role in visualizations, the analysis focuses on the highest-paying roles and uses employee-count thresholds where appropriate to avoid misleading comparisons from roles with very few observations.

---

### Experience Analysis

Years of experience is analyzed against salary to understand how compensation changes across different experience levels.

---

## Technologies Used

### Programming & Analysis

- Python
- Pandas
- NumPy

### Data Visualization

- Matplotlib
- Seaborn

### Database & SQL

- PostgreSQL
- SQL

### Business Intelligence

- Microsoft Power BI

### Development Environment

- Jupyter Notebook
- VS Code
- GitHub
