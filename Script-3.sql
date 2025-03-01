/*1) Распределение (количество) клиентов по сферам деятельности, по убыванию количества*/
SELECT 
    job_industry_category,
    COUNT(*) AS customers_count
FROM customer
GROUP BY job_industry_category
ORDER BY customers_count DESC;

/*2) Сумма транзакций за каждый месяц по сферам деятельности, сортировка по месяцу и сфере деятельности*/
SELECT 
    EXTRACT(MONTH FROM t.transaction_date::date) AS transaction_month,
    c.job_industry_category,
    SUM(t.list_price) AS total_transaction_sum
FROM transaction t
JOIN customer c 
    ON t.customer_id = c.customer_id
GROUP BY 
    EXTRACT(MONTH FROM t.transaction_date::date),
    c.job_industry_category
ORDER BY 
    transaction_month,
    c.job_industry_category;

/*3)Количество онлайн-заказов для всех брендов, подтверждённые заказы у клиентов из сферы IT*/
SELECT 
    t.brand,
    COUNT(*) AS online_orders_count
FROM transaction t
JOIN customer c 
    ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'IT'
  AND t.online_order = 'Yes'       -- или '1' / 'True' в зависимости от хранимого значения
  AND t.order_status = 'Approved'  -- условие для подтверждённого заказа
GROUP BY t.brand;

/*4) Сумма всех транзакций, максимум, минимум и количество транзакций по каждому клиенту.*/
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(t.list_price) AS total_spent,
    MAX(t.list_price) AS max_price,
    MIN(t.list_price) AS min_price,
    COUNT(t.transaction_id) AS transaction_count
FROM transaction t
JOIN customer c 
    ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name
ORDER BY 
    total_spent DESC,
    transaction_count DESC;

SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(t.list_price) OVER (PARTITION BY c.customer_id) AS total_spent,
    MAX(t.list_price) OVER (PARTITION BY c.customer_id) AS max_price,
    MIN(t.list_price) OVER (PARTITION BY c.customer_id) AS min_price,
    COUNT(t.transaction_id) OVER (PARTITION BY c.customer_id) AS transaction_count
FROM transaction t
JOIN customer c 
    ON t.customer_id = c.customer_id
ORDER BY 
    total_spent DESC,
    transaction_count DESC;
 

/*5) Сумма всех транзакций, максимум, минимум и количество транзакций по каждому клиенту.*/
WITH sums AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(t.list_price) AS total_spent
    FROM transaction t
    JOIN customer c 
        ON t.customer_id = c.customer_id
    GROUP BY 
        c.customer_id, 
        c.first_name, 
        c.last_name
    HAVING SUM(t.list_price) IS NOT NULL
)
SELECT 
    first_name,
    last_name,
    total_spent
FROM sums
ORDER BY total_spent
LIMIT 1;

WITH sums AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(t.list_price) AS total_spent
    FROM transaction t
    JOIN customer c 
        ON t.customer_id = c.customer_id
    GROUP BY 
        c.customer_id, 
        c.first_name, 
        c.last_name
    HAVING SUM(t.list_price) IS NOT NULL
)
SELECT 
    first_name,
    last_name,
    total_spent
FROM sums
ORDER BY total_spent DESC
LIMIT 1;

/*6) Самые первые транзакции клиентов (с помощью оконных функций)*/
SELECT *
FROM (
    SELECT 
        t.transaction_id,
        t.product_id,
        t.customer_id,
        t.transaction_date,
        t.online_order,
        t.order_status,
        t.brand,
        t.product_line,
        t.product_class,
        t.product_size,
        t.list_price,
        t.standard_cost,
        c.first_name,
        c.last_name,
        ROW_NUMBER() OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date ASC) AS rn
    FROM transaction t
    JOIN customer c
        ON t.customer_id = c.customer_id
) sub
WHERE rn = 1;


/*7) Имена, фамилии и профессии клиентов с максимальным интервалом между транзакциями (в днях)*/
WITH cte AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.job_title,
        t.transaction_date::date AS transaction_date,
        LAG(t.transaction_date::date) OVER (
            PARTITION BY c.customer_id 
            ORDER BY t.transaction_date::date
        ) AS prev_trans_date
    FROM transaction t
    JOIN customer c
        ON t.customer_id = c.customer_id
),
diffs AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        job_title,
        (transaction_date - prev_trans_date) AS day_diff
    FROM cte
    WHERE prev_trans_date IS NOT NULL
),
max_diff_per_customer AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        job_title,
        MAX(day_diff) AS max_day_diff
    FROM diffs
    GROUP BY 
        customer_id,
        first_name,
        last_name,
        job_title
),
global_max AS (
    SELECT MAX(max_day_diff) AS global_max_diff
    FROM max_diff_per_customer
)
SELECT 
    m.first_name,
    m.last_name,
    m.job_title
FROM max_diff_per_customer m
JOIN global_max g
    ON m.max_day_diff = g.global_max_diff;


