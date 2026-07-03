
# Foodie-Fi SQL Case Study

## Overview

This project contains solutions to the Foodie-Fi SQL Case Study. The objective is to analyze customer subscription behavior, churn, upgrades, and business performance using PostgreSQL.

## Dataset

Source:
https://www.db-fiddle.com/f/jbahqhW5AQwqV1RZ2xExEz/0


## Skills Used

- PostgreSQL
- Joins
- CTEs
- Window Functions
- Aggregate Functions
- Date Functions
- CASE Statements

---

## Business Questions

1. Total customers
2. Monthly distribution of trial starts
3. Plan events after 2020
4. Churn rate
5. Customers churning after free trial
6. Customer plans after trial
7. Customer plan breakdown on 2020-12-31
8. Annual plan upgrades
9. Average days to annual plan
10. 30-day bucket analysis
11. Pro Monthly → Basic Monthly downgrades

---

## Results

| Question | Answer |
|-----------|---------|
| Total Customers | 1000 |
| Churn Customers | 307 |
| Churn Rate | 30.7% |
| Churn After Trial | 92 |
| Annual Upgrades (2020) | 195 |
| Avg Days to Annual | 104.6 |
| Pro → Basic Downgrade | 0 |

---

## SQL File

All SQL queries are available in:

`foodie_fi_case_study.sql`

---

## Key SQL Concepts

- Common Table Expressions (CTEs)
- LEAD()
- ROW_NUMBER()
- DATE_TRUNC()
- CASE
- COUNT DISTINCT
- GROUP BY
- Aggregate Functions
