SELECT
    customerName,
    country,
    creditLimit
FROM customers
WHERE creditLimit > (
    SELECT AVG(creditLimit)
    FROM customers
)
ORDER BY creditLimit DESC;

SELECT
    c.customerName,
    c.country,
    (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.customerNumber = c.customerNumber
    ) AS total_orders
FROM customers c;

SELECT
    productName,
    productLine,
    buyPrice,
    RANK() OVER (
        PARTITION BY productLine
        ORDER BY buyPrice DESC
    ) AS ranking
FROM products;

WITH ranked_products AS (
    SELECT
        productName,
        productLine,
        buyPrice,
        RANK() OVER (
            PARTITION BY productLine
            ORDER BY buyPrice DESC
        ) AS ranking
    FROM products
)

SELECT *
FROM ranked_products
WHERE ranking <= 3;

SELECT
    customerNumber,
    paymentDate,
    amount,
    SUM(amount) OVER (
        PARTITION BY customerNumber
        ORDER BY paymentDate
    ) AS running_total
FROM payments;

SELECT
    c.customerName,
    SUM(p.amount) AS total_payment,

    CASE
        WHEN SUM(p.amount) > 100000 THEN 'Platinum'
        WHEN SUM(p.amount) > 50000 THEN 'Gold'
        ELSE 'Silver'
    END AS customer_level

FROM customers c
JOIN payments p
    ON c.customerNumber = p.customerNumber

GROUP BY c.customerNumber, c.customerName;

SELECT
    productName,
    productLine,
    productVendor,
    buyPrice,

    ROW_NUMBER() OVER (
        PARTITION BY productLine, productVendor
        ORDER BY buyPrice DESC
    ) AS productRank

FROM products;

SELECT *
FROM orders o
WHERE customerNumber IN (
   SELECT customerNumber
   FROM customers
);

WITH customer_payments AS (

    SELECT
        c.country,
        c.customerName,
        SUM(p.amount) AS totalPayment

    FROM customers c
    JOIN payments p
        ON c.customerNumber = p.customerNumber

    GROUP BY c.country, c.customerName
),

ranked_customers AS (

    SELECT
        country,
        customerName,
        totalPayment,

        RANK() OVER (
            PARTITION BY country
            ORDER BY totalPayment DESC
        ) AS ranking

    FROM customer_payments
)

SELECT *
FROM ranked_customers
WHERE ranking = 1;
