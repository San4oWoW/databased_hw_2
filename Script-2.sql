 /*Уникальные бренды со стандартной стоимостью выше 1500 долларов*/
SELECT DISTINCT brand
FROM transaction
WHERE standard_cost > 1500;

/*Подтвержденные транзакции за период '2017-04-01' - '2017-04-09'*/
SELECT *
FROM transaction
WHERE order_status = 'Approved'
AND transaction_date BETWEEN '2017-04-01' AND '2017-04-09';

/*Профессии клиентов из IT или Financial Services, начинающиеся с "Senior*/
SELECT DISTINCT job_title
FROM customer
WHERE job_industry_category IN ('IT', 'Financial Services')
AND job_title LIKE 'Senior%';

/*Бренды, закупаемые клиентами из Financial Services*/
SELECT DISTINCT t.brand
FROM transaction t
JOIN customer c ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'Financial Services';

/*10 клиентов, которые оформили онлайн-заказ продукции из указанных брендов*/
SELECT DISTINCT c.*
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE t.online_order = 'True'
AND t.brand IN ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
LIMIT 10;

/*Клиенты без транзакций*/
SELECT c.*
FROM customer c
LEFT JOIN transaction t ON c.customer_id = t.customer_id
WHERE t.customer_id IS NULL;

/*Клиенты из IT с транзакциями с максимальной стандартной стоимостью*/
WITH max_cost AS (
    SELECT MAX(standard_cost) AS max_standard_cost
    FROM transaction
)
SELECT DISTINCT c.*
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
JOIN max_cost mc ON t.standard_cost = mc.max_standard_cost
WHERE c.job_industry_category = 'IT';

/*Клиенты из IT и Health с подтвержденными транзакциями за период '2017-07-07' - '2017-07-17'*/
SELECT DISTINCT c.*
FROM customer c
JOIN transaction t ON c.customer_id = t.customer_id
WHERE c.job_industry_category IN ('IT', 'Health')
AND t.order_status = 'Approved'
AND t.transaction_date BETWEEN '2017-07-07' AND '2017-07-17';
