# Foodie-Fi SQL Case Study

## Question 1: How many customers has Foodie-Fi ever had?

### SQL Query

```sql
SELECT COUNT(DISTINCT(customer_id))
FROM subscriptions;
```

### Answer

Foodie-Fi has **1,000** unique customers.

---

## Question 2: What is the monthly distribution of trial `start_date` values for our dataset? Use the start of the month as the group by value.

### SQL Query

```sql
SELECT
    DATE_TRUNC('month', start_date) AS month_start,
    COUNT(*) AS trial
FROM subscriptions
WHERE plan_id = 0
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY month_start;
```

### Answer

| Month          | Trial Customers |
| -------------- | --------------: |
| January 2020   |              88 |
| February 2020  |              68 |
| March 2020     |              94 |
| April 2020     |              81 |
| May 2020       |              88 |
| June 2020      |              79 |
| July 2020      |              89 |
| August 2020    |              88 |
| September 2020 |              87 |
| October 2020   |              79 |
| November 2020  |              75 |
| December 2020  |              84 |

---

## Question 3: What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`.

### SQL Query

```sql
SELECT
    p.plan_name AS plan_name,
    COUNT(*) AS subscriptions
FROM plans p
JOIN subscriptions s
ON p.plan_id = s.plan_id
WHERE s.start_date >= '2020-01-01'
GROUP BY p.plan_name;
```

### Answer

| Plan Name     | Number of Events |
| ------------- | ---------------: |
| Trial         |             1000 |
| Basic Monthly |              546 |
| Pro Monthly   |              539 |
| Pro Annual    |              258 |
| Churn         |              307 |

> **Note:** The case study asks for plan events **after the year 2020**, but this query uses `start_date >= '2020-01-01'`, which includes all events during 2020. If you're submitting this project, consider correcting the filter to match the question.

---

## Question 4: What is the customer count and percentage of customers who have churned? Round the percentage to 1 decimal place.

### SQL Query

```sql
SELECT
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(
        (
            COUNT(DISTINCT customer_id) * 100.0 /
            (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)
        )::NUMERIC,
        1
    ) AS percentage
FROM subscriptions
WHERE plan_id = 4;
```

### Answer

| Customer Count | Percentage |
| -------------: | ---------: |
|            307 |      30.7% |

### Summary

* Total Customers: **1,000**
* Churned Customers: **307**
* Churn Rate: **30.7%**
* Monthly Trial Signups: **Highest in March (94)** and **Lowest in February (68)**.

# Foodie-Fi SQL Case Study

## Question 5: How many customers have churned straight after their initial free trial? What percentage of customers is this?

### SQL Query

```sql
WITH customer_plans AS (
    SELECT
        customer_id,
        plan_id,
        LEAD(plan_id) OVER (
            PARTITION BY customer_id
            ORDER BY start_date
        ) AS next_plan
    FROM subscriptions
)

SELECT
    COUNT(*) AS churned_customer,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),
        1
    ) AS churn_percentage
FROM customer_plans
WHERE plan_id = 0
AND next_plan = 4;
```

### Answer

| Churned Customers | Percentage |
| ----------------: | ---------: |
|                92 |       9.2% |

---

# Question 6: What is the number and percentage of customer plans after their initial free trial?

### SQL Query

```sql
WITH customer_plans AS (
    SELECT
        customer_id,
        plan_id,
        LEAD(plan_id) OVER (
            PARTITION BY customer_id
            ORDER BY start_date
        ) AS nxt_plan
    FROM subscriptions
)

SELECT
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),
        1
    ) AS customer_percentage
FROM customer_plans
WHERE plan_id = 0
AND nxt_plan IN (1, 2, 3);
```

### Answer

| Customers | Percentage |
| --------: | ---------: |
|       908 |      90.8% |

---

# Question 7: What is the customer count and percentage breakdown of all 5 `plan_name` values at **2020-12-31**?

### SQL Query

```sql
WITH latest_plan AS (
    SELECT
        customer_id,
        plan_id,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY start_date DESC
        ) AS rnk
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
)

SELECT
    p.plan_name,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),
        1
    ) AS percentage
FROM latest_plan pl
JOIN plans p
ON pl.plan_id = p.plan_id
WHERE rnk = 1
GROUP BY p.plan_name, p.plan_id
ORDER BY p.plan_id;
```

### Answer

| Plan Name     | Customer Count | Percentage |
| ------------- | -------------: | ---------: |
| Trial         |             19 |       1.9% |
| Basic Monthly |            224 |      22.4% |
| Pro Monthly   |            326 |      32.6% |
| Pro Annual    |            195 |      19.5% |

> **Note:** The expected output should also include the **Churn** plan if customers were on that plan as of **2020-12-31**. Verify your query or dataset if it is missing.

---

# Question 8: How many customers have upgraded to an annual plan in 2020?

### SQL Query

```sql
SELECT
    COUNT(DISTINCT customer_id) AS customers
FROM subscriptions
WHERE plan_id = 3
AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
```

### Answer

**195** customers upgraded to the **Pro Annual** plan during 2020.

---

## Summary

* Customers who churned immediately after the trial: **92 (9.2%)**
* Customers who continued after the trial: **908 (90.8%)**
* Customers upgraded to the annual plan in 2020: **195**
* Most customers on **2020-12-31** were on the **Pro Monthly** plan (326 customers).

# Foodie-Fi SQL Case Study

## Question 9: How many days on average does it take a customer to upgrade to an annual plan from the day they join Foodie-Fi?

### SQL Query

```sql
SELECT
    ROUND(AVG(s2.start_date - s1.start_date), 1) AS avg_days
FROM subscriptions s1
JOIN subscriptions s2
ON s1.customer_id = s2.customer_id
WHERE s1.plan_id = 0
AND s2.plan_id = 3;
```

### Answer

The average time taken for a customer to upgrade to the **Pro Annual** plan is **104.6 days**.

---

# Question 10: Can you further break down this average value into 30-day periods? (i.e. 0–30 days, 31–60 days, etc.)

### SQL Query

```sql
WITH customer_days AS (
    SELECT
        s1.customer_id,
        (s2.start_date - s1.start_date) AS days_to_annual
    FROM subscriptions s1
    JOIN subscriptions s2
    ON s1.customer_id = s2.customer_id
    WHERE s1.plan_id = 0
)

SELECT
    CASE
        WHEN days_to_annual BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN days_to_annual BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN days_to_annual BETWEEN 61 AND 90 THEN '61-90 days'
        WHEN days_to_annual BETWEEN 91 AND 120 THEN '91-120 days'
        WHEN days_to_annual BETWEEN 121 AND 150 THEN '121-150 days'
        WHEN days_to_annual BETWEEN 151 AND 180 THEN '151-180 days'
        WHEN days_to_annual BETWEEN 181 AND 210 THEN '181-210 days'
        WHEN days_to_annual BETWEEN 211 AND 240 THEN '211-240 days'
        WHEN days_to_annual BETWEEN 241 AND 270 THEN '241-270 days'
        WHEN days_to_annual BETWEEN 271 AND 300 THEN '271-300 days'
        WHEN days_to_annual BETWEEN 301 AND 330 THEN '301-330 days'
        ELSE '331-360 days'
    END AS period,
    COUNT(*)
FROM customer_days
GROUP BY period
ORDER BY MIN(days_to_annual);
```

### Answer

| Period       | Customer Count |
| ------------ | -------------: |
| 0–30 days    |           2058 |
| 31–60 days   |            100 |
| 61–90 days   |             94 |
| 91–120 days  |            112 |
| 121–150 days |            117 |
| 151–180 days |             92 |
| 181–210 days |             50 |
| 211–240 days |              8 |
| 241–270 days |              7 |
| 271–300 days |              4 |
| 301–330 days |              1 |
| 331–360 days |              7 |

> **Note:** The first bucket (0–30 days = 2058) is unusually high. This query is missing the condition `AND s2.plan_id = 3` inside the CTE, so it counts all subscription changes instead of only upgrades to the annual plan.

---

# Question 11: How many customers downgraded from a Pro Monthly plan to a Basic Monthly plan in 2020?

### SQL Query

```sql
WITH downgrade AS (
    SELECT
        customer_id,
        plan_id,
        start_date,
        LEAD(plan_id) OVER (
            PARTITION BY customer_id
            ORDER BY start_date
        ) AS new_id
    FROM subscriptions
)

SELECT
    COUNT(DISTINCT customer_id) AS customer_downgrade
FROM downgrade
WHERE plan_id = 2
AND new_id = 1
AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
```

### Answer

No customers downgraded from the **Pro Monthly** plan to the **Basic Monthly** plan during **2020**.

| Customer Downgrades |
| ------------------: |
|                   0 |

---

# Project Summary

This case study demonstrates SQL analysis of a subscription-based business using PostgreSQL. The analysis covers customer acquisition, churn, plan transitions, annual upgrades, subscription timelines, and customer lifecycle metrics.

## SQL Concepts Used

* SELECT
* WHERE
* GROUP BY
* ORDER BY
* JOIN
* COUNT
* DISTINCT
* DATE_TRUNC()
* CASE
* Common Table Expressions (CTEs)
* LEAD()
* ROW_NUMBER()
* Aggregate Functions
* Window Functions
