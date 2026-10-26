CREATE DATABASE financial_risk_db;

USE financial_risk_db;

USE financial_risk_db;

SELECT COUNT(*) AS total_loans
FROM loan_applications;

SELECT *
FROM loan_applications
LIMIT 10;

-- Total loans, default loans aur default rate
SELECT
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications;

-- Loan grade ke according default rate
SELECT
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY loan_grade
ORDER BY default_rate_pct DESC;

-- Income group ke according default rate
SELECT
    income_group,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY income_group
ORDER BY default_rate_pct DESC;

SELECT COUNT(*) FROM loan_applications;


-- Overall loan risk summary
SELECT
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    COUNT(*) - SUM(loan_status) AS non_default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount
FROM loan_applications;


-- Loan grade ke according risk
SELECT
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY loan_grade
ORDER BY default_rate_pct DESC;


-- Loan purpose analysis
SELECT
    loan_intent,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY loan_intent
ORDER BY default_rate_pct DESC;


-- Home ownership analysis
SELECT
    person_home_ownership,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY person_home_ownership
ORDER BY default_rate_pct DESC;


SELECT
    loan_grade,
    loan_int_rate,
    CASE
        WHEN loan_int_rate < 10 THEN 'Low Rate'
        WHEN loan_int_rate <= 15 THEN 'Medium Rate'
        ELSE 'High Rate'
    END AS interest_rate_category
FROM loan_applications
LIMIT 20;


-- Ab business analysis
SELECT
    CASE
        WHEN loan_int_rate < 10 THEN 'Low Rate'
        WHEN loan_int_rate <= 15 THEN 'Medium Rate'
        ELSE 'High Rate'
    END AS interest_rate_category,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY interest_rate_category
ORDER BY default_rate_pct DESC;


SELECT
    loan_intent,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY loan_intent
HAVING SUM(loan_status) > 500
ORDER BY default_rate_pct DESC;

-- where
SELECT
    loan_grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount
FROM loan_applications
WHERE loan_amnt > 10000
GROUP BY loan_grade
ORDER BY total_loans DESC;


-- having
 SELECT
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM loan_applications
GROUP BY loan_grade
HAVING SUM(loan_status) > 100
ORDER BY default_rate_pct DESC;


WITH grade_risk AS (
    SELECT
        loan_grade,
        COUNT(*) AS total_loans,
        SUM(loan_status) AS default_loans,
        ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
    FROM loan_applications
    GROUP BY loan_grade
)
SELECT *
FROM grade_risk
WHERE default_rate_pct > 25
ORDER BY default_rate_pct DESC;


SELECT
    loan_grade,
    loan_amnt,
    loan_int_rate,
    loan_status,
    ROW_NUMBER() OVER (
        PARTITION BY loan_grade
        ORDER BY loan_int_rate DESC
    ) AS rate_rank
FROM loan_applications
LIMIT 20;



WITH ranked_loans AS (
    SELECT
        loan_grade,
        loan_amnt,
        loan_int_rate,
        loan_status,
        ROW_NUMBER() OVER (
            PARTITION BY loan_grade
            ORDER BY loan_int_rate DESC
        ) AS rate_rank
    FROM loan_applications
)
SELECT
    loan_grade,
    loan_amnt,
    loan_int_rate,
    loan_status,
    rate_rank
FROM ranked_loans
WHERE rate_rank <= 3
ORDER BY loan_grade, rate_rank;



WITH grade_analysis AS (
    SELECT
        loan_grade,
        COUNT(*) AS total_loans,
        SUM(loan_status) AS default_loans,
        AVG(loan_status) * 100 AS grade_default_rate
    FROM loan_applications
    GROUP BY loan_grade
)
SELECT
    loan_grade,
    total_loans,
    default_loans,
    ROUND(grade_default_rate, 2) AS grade_default_rate_pct,
    ROUND(
        AVG(grade_default_rate) OVER (), 2
    ) AS avg_grade_rate_pct,
    ROUND(
        SUM(default_loans) OVER () * 100.0
        / SUM(total_loans) OVER (), 2
    ) AS overall_default_rate_pct
FROM grade_analysis
ORDER BY grade_default_rate DESC;


SELECT
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_status) AS default_loans,
    COUNT(*) - SUM(loan_status) AS non_default_loans,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate
FROM loan_applications
GROUP BY loan_grade
ORDER BY default_rate_pct DESC;