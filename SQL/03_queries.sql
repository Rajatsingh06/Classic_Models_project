-- =====================================================================
--  ClassicModels Query Challenge  |  03_queries.sql
--  Solutions to every business question, grouped by analysis area.
--
--  Sections
--    A  Customer Analysis   (36 questions)
--    B  Product Analysis    (33 questions)
--    C  Payment Analysis    (31 questions)
--    D  Bonus - JOINs and business insights (8 questions, optional)
--
--  Sections A-C only use the skills listed in the brief:
--  SELECT, WHERE, ORDER BY, GROUP BY, HAVING, LIKE, IN, LIMIT, OFFSET,
--  aggregate functions, subqueries, filtering and sorting (no JOINs).
--
--  Works on MySQL 8 and MariaDB (ONLY_FULL_GROUP_BY safe) and on the
--  bundled SQLite database via scripts/run_queries.py.
-- =====================================================================
USE classicmodels;


-- #####################################################################
--  SECTION A - CUSTOMER ANALYSIS
-- #####################################################################

-- ---------- A1. Customer locations ----------------------------------

-- [A01] List customer locations
-- Question : Show the name, city, state and country of every customer, sorted by country, then city, then name. Display the first 25 rows.
-- Skills   : SELECT, ORDER BY, LIMIT
SELECT customerName, city, state, country
FROM customers
ORDER BY country, city, customerName
LIMIT 25;

-- [A02] Customers in the USA
-- Question : Which customers are located in the USA? Sort them by state and city (first 25).
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT customerNumber, customerName, city, state
FROM customers
WHERE country = 'USA'
ORDER BY state, city, customerName
LIMIT 25;

-- [A03] Customers in France, Germany or Spain
-- Question : List customers based in France, Germany or Spain, sorted by country then name (first 25).
-- Skills   : WHERE, IN, ORDER BY, LIMIT
SELECT customerNumber, customerName, city, country
FROM customers
WHERE country IN ('France', 'Germany', 'Spain')
ORDER BY country, customerName
LIMIT 25;

-- [A04] Customers outside North America
-- Question : How many customers are located outside the USA and Canada?
-- Skills   : WHERE, NOT IN, COUNT
SELECT COUNT(*) AS customers_outside_usa_canada
FROM customers
WHERE country NOT IN ('USA', 'Canada');

-- [A05] Countries we sell to
-- Question : Which distinct countries do our customers come from?
-- Skills   : SELECT DISTINCT, ORDER BY
SELECT DISTINCT country
FROM customers
ORDER BY country;

-- [A06] Customers per country
-- Question : How many customers does each country have? Show the biggest markets first.
-- Skills   : GROUP BY, COUNT, ORDER BY
SELECT country, COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC, country;

-- [A07] Major customer countries
-- Question : Which countries have at least 100 customers?
-- Skills   : GROUP BY, HAVING, COUNT
SELECT country, COUNT(*) AS total_customers
FROM customers
GROUP BY country
HAVING COUNT(*) >= 100
ORDER BY total_customers DESC;

-- [A08] Customer-heavy cities
-- Question : Which cities have more than 20 customers? Show the top 15.
-- Skills   : GROUP BY (two columns), HAVING, LIMIT
SELECT city, country, COUNT(*) AS total_customers
FROM customers
GROUP BY city, country
HAVING COUNT(*) > 20
ORDER BY total_customers DESC, city
LIMIT 15;

-- [A09] Customers with no state recorded
-- Question : For each country, how many customers have no state on file? Show the top 10 countries.
-- Skills   : WHERE ... IS NULL, GROUP BY, LIMIT
SELECT country, COUNT(*) AS customers_without_state
FROM customers
WHERE state IS NULL
GROUP BY country
ORDER BY customers_without_state DESC, country
LIMIT 10;

-- ---------- A2. Credit limits ---------------------------------------

-- [A10] Very high credit limits
-- Question : Which customers have a credit limit of 200,000 or more? Show the top 20.
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE creditLimit >= 200000
ORDER BY creditLimit DESC, customerName
LIMIT 20;

-- [A11] Mid-range credit limits
-- Question : How many customers have a credit limit between 50,000 and 75,000 (inclusive)?
-- Skills   : WHERE, BETWEEN, COUNT
SELECT COUNT(*) AS customers_in_range
FROM customers
WHERE creditLimit BETWEEN 50000 AND 75000;

-- [A12] Top 10 credit limits
-- Question : Who are the 10 customers with the highest credit limit?
-- Skills   : ORDER BY, LIMIT
SELECT customerNumber, customerName, country, creditLimit
FROM customers
ORDER BY creditLimit DESC, customerNumber
LIMIT 10;

-- [A13] Lowest non-zero credit limits
-- Question : Which 10 customers have the lowest credit limit above zero?
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE creditLimit > 0
ORDER BY creditLimit ASC, customerNumber
LIMIT 10;

-- [A14] Customers with no credit
-- Question : Which customers have a credit limit of zero? Show 15 alphabetically.
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT customerNumber, customerName, country
FROM customers
WHERE creditLimit = 0
ORDER BY customerName
LIMIT 15;

-- [A15] Credit limit statistics by country
-- Question : For each country show the number of customers and the average, minimum, maximum and total credit limit. Sort by average credit, highest first.
-- Skills   : GROUP BY, COUNT, AVG, MIN, MAX, SUM, ROUND
SELECT country,
       COUNT(*)                   AS customers,
       ROUND(AVG(creditLimit), 2) AS avg_credit,
       MIN(creditLimit)           AS min_credit,
       MAX(creditLimit)           AS max_credit,
       SUM(creditLimit)           AS total_credit
FROM customers
GROUP BY country
ORDER BY avg_credit DESC;

-- [A16] Countries with above-average credit
-- Question : Which countries have an average credit limit higher than the average credit limit of all customers?
-- Skills   : GROUP BY, HAVING, subquery
SELECT country, ROUND(AVG(creditLimit), 2) AS avg_credit
FROM customers
GROUP BY country
HAVING AVG(creditLimit) > (SELECT AVG(creditLimit) FROM customers)
ORDER BY avg_credit DESC;

-- [A17] Overall credit exposure
-- Question : What are the total, average, lowest and highest credit limits across all customers?
-- Skills   : SUM, AVG, MIN, MAX
SELECT SUM(creditLimit)           AS total_credit,
       ROUND(AVG(creditLimit), 2) AS avg_credit,
       MIN(creditLimit)           AS min_credit,
       MAX(creditLimit)           AS max_credit
FROM customers;

-- ---------- A3. Customer searches -----------------------------------

-- [A18] Names starting with 'A'
-- Question : Find customers whose name starts with the letter A (first 20).
-- Skills   : LIKE 'A%', ORDER BY, LIMIT
SELECT customerNumber, customerName, country
FROM customers
WHERE customerName LIKE 'A%'
ORDER BY customerName
LIMIT 20;

-- [A19] Names containing 'Gift'
-- Question : Find customers with 'Gift' anywhere in their name (first 20).
-- Skills   : LIKE '%Gift%', ORDER BY, LIMIT
SELECT customerNumber, customerName, country
FROM customers
WHERE customerName LIKE '%Gift%'
ORDER BY customerName
LIMIT 20;

-- [A20] Limited companies in the UK, Ireland or Australia
-- Question : Find customers whose name contains 'Ltd' and that are based in the UK, Ireland or Australia (first 20).
-- Skills   : LIKE, AND, IN, LIMIT
SELECT customerNumber, customerName, country
FROM customers
WHERE customerName LIKE '%Ltd%'
  AND country IN ('UK', 'Ireland', 'Australia')
ORDER BY country, customerName
LIMIT 20;

-- [A21] Contact person search
-- Question : Find customers whose contact first name starts with 'Ma' and whose contact last name ends with 'son'.
-- Skills   : LIKE with two patterns, AND
SELECT customerNumber, customerName, contactFirstName, contactLastName
FROM customers
WHERE contactFirstName LIKE 'Ma%'
  AND contactLastName LIKE '%son'
ORDER BY contactLastName, contactFirstName, customerNumber
LIMIT 20;

-- [A22] Single-character wildcard
-- Question : Find customers whose name has 'a' as its second letter (first 15).
-- Skills   : LIKE '_a%', ORDER BY, LIMIT
SELECT customerNumber, customerName
FROM customers
WHERE customerName LIKE '_a%'
ORDER BY customerName
LIMIT 15;

-- [A23] City search
-- Question : Find customers in cities starting with 'San ' and show how many customers each such city has.
-- Skills   : LIKE, GROUP BY, COUNT
SELECT city, country, COUNT(*) AS total_customers
FROM customers
WHERE city LIKE 'San %'
GROUP BY city, country
ORDER BY total_customers DESC;

-- ---------- A4. Sales representatives -------------------------------

-- [A24] Customers of one sales rep
-- Question : List the customers assigned to sales rep 1010 (first 20, alphabetical).
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE salesRepEmployeeNumber = 1010
ORDER BY customerName
LIMIT 20;

-- [A25] Customers per sales rep
-- Question : How many customers does each sales rep look after? Show the 10 largest portfolios.
-- Skills   : GROUP BY, COUNT, ORDER BY, LIMIT
SELECT salesRepEmployeeNumber, COUNT(*) AS total_customers
FROM customers
WHERE salesRepEmployeeNumber IS NOT NULL
GROUP BY salesRepEmployeeNumber
ORDER BY total_customers DESC, salesRepEmployeeNumber
LIMIT 10;

-- [A26] Overloaded sales reps
-- Question : Which sales reps look after more than 100 customers?
-- Skills   : GROUP BY, HAVING
SELECT salesRepEmployeeNumber, COUNT(*) AS total_customers
FROM customers
WHERE salesRepEmployeeNumber IS NOT NULL
GROUP BY salesRepEmployeeNumber
HAVING COUNT(*) > 100
ORDER BY total_customers DESC;

-- [A27] Customers without a sales rep
-- Question : Which customers have no sales rep assigned? (first 20)
-- Skills   : WHERE ... IS NULL, ORDER BY, LIMIT
SELECT customerNumber, customerName, country
FROM customers
WHERE salesRepEmployeeNumber IS NULL
ORDER BY country, customerName
LIMIT 20;

-- [A28] Customers of the busiest sales rep
-- Question : List customers (first 20) of the sales rep who manages the most customers.
-- Skills   : subquery in WHERE, GROUP BY, ORDER BY, LIMIT
SELECT customerNumber, customerName, country
FROM customers
WHERE salesRepEmployeeNumber = (SELECT salesRepEmployeeNumber
                                FROM customers
                                WHERE salesRepEmployeeNumber IS NOT NULL
                                GROUP BY salesRepEmployeeNumber
                                ORDER BY COUNT(*) DESC
                                LIMIT 1)
ORDER BY customerName
LIMIT 20;

-- [A29] Sales reps with no customers
-- Question : Which sales reps have not been assigned any customers yet?
-- Skills   : NOT IN subquery, WHERE
SELECT employeeNumber, firstName, lastName, officeCode
FROM employees
WHERE jobTitle = 'Sales Rep'
  AND employeeNumber NOT IN (SELECT salesRepEmployeeNumber
                             FROM customers
                             WHERE salesRepEmployeeNumber IS NOT NULL);

-- [A30] Reps serving Japan
-- Question : Which employees are the sales reps of Japanese customers?
-- Skills   : IN subquery
SELECT employeeNumber, firstName, lastName, jobTitle
FROM employees
WHERE employeeNumber IN (SELECT salesRepEmployeeNumber
                         FROM customers
                         WHERE country = 'Japan')
ORDER BY lastName;

-- ---------- A5. Customer payments & activity ------------------------

-- [A31] Above-average credit limit
-- Question : Which customers have a credit limit higher than the average? Show the top 20.
-- Skills   : subquery, ORDER BY, LIMIT
SELECT customerNumber, customerName, creditLimit
FROM customers
WHERE creditLimit > (SELECT AVG(creditLimit) FROM customers)
ORDER BY creditLimit DESC, customerNumber
LIMIT 20;

-- [A32] Pagination - page 3
-- Question : Customers are shown 20 per page ordered by customer number. Show page 3.
-- Skills   : ORDER BY, LIMIT, OFFSET
SELECT customerNumber, customerName, city, country
FROM customers
ORDER BY customerNumber
LIMIT 20 OFFSET 40;

-- [A33] Customers who never paid
-- Question : Which customers have never made a payment? Show the 20 with the highest credit limit.
-- Skills   : NOT IN subquery, ORDER BY, LIMIT
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE customerNumber NOT IN (SELECT customerNumber FROM payments)
ORDER BY creditLimit DESC, customerNumber
LIMIT 20;

-- [A34] Customers who never ordered
-- Question : How many customers have never placed an order?
-- Skills   : NOT IN subquery, COUNT
SELECT COUNT(*) AS customers_without_orders
FROM customers
WHERE customerNumber NOT IN (SELECT customerNumber FROM orders);

-- [A35] Big-spending customers
-- Question : Which customers have paid more than 400,000 in total? (first 20 by name)
-- Skills   : IN subquery with GROUP BY / HAVING / SUM
SELECT customerNumber, customerName, country
FROM customers
WHERE customerNumber IN (SELECT customerNumber
                         FROM payments
                         GROUP BY customerNumber
                         HAVING SUM(amount) > 400000)
ORDER BY customerName
LIMIT 20;

-- [A36] Highest credit limit in each country
-- Question : Which customer has the highest credit limit in each country?
-- Skills   : correlated subquery, MAX
SELECT country, customerName, creditLimit
FROM customers c1
WHERE creditLimit = (SELECT MAX(creditLimit)
                     FROM customers c2
                     WHERE c2.country = c1.country)
ORDER BY country, customerName;


-- #####################################################################
--  SECTION B - PRODUCT ANALYSIS
-- #####################################################################

-- ---------- B1. Product prices --------------------------------------

-- [B01] Product catalogue
-- Question : List the code, name, product line, buy price and MSRP of all products alphabetically (first 25).
-- Skills   : SELECT, ORDER BY, LIMIT
SELECT productCode, productName, productLine, buyPrice, MSRP
FROM products
ORDER BY productName
LIMIT 25;

-- [B02] Classic Cars
-- Question : Show the 20 most expensive products (by MSRP) in the 'Classic Cars' line.
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT productCode, productName, MSRP
FROM products
WHERE productLine = 'Classic Cars'
ORDER BY MSRP DESC, productName
LIMIT 20;

-- [B03] Motorcycles, planes and ships
-- Question : List products in the Motorcycles, Planes or Ships lines, sorted by line then name (first 25).
-- Skills   : WHERE, IN, ORDER BY, LIMIT
SELECT productName, productLine, productScale, MSRP
FROM products
WHERE productLine IN ('Motorcycles', 'Planes', 'Ships')
ORDER BY productLine, productName
LIMIT 25;

-- [B04] Products that are not cars
-- Question : How many products are not in the Classic Cars or Vintage Cars lines?
-- Skills   : NOT IN, COUNT
SELECT COUNT(*) AS non_car_products
FROM products
WHERE productLine NOT IN ('Classic Cars', 'Vintage Cars');

-- [B05] Expensive to buy
-- Question : Which products cost more than 80 to buy? Show the top 20 by buy price.
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT productCode, productName, productLine, buyPrice
FROM products
WHERE buyPrice > 80
ORDER BY buyPrice DESC, productName
LIMIT 20;

-- [B06] Retail price band
-- Question : How many products have an MSRP between 100 and 150?
-- Skills   : WHERE, BETWEEN, COUNT
SELECT COUNT(*) AS products_in_price_band
FROM products
WHERE MSRP BETWEEN 100 AND 150;

-- [B07] Top 10 most expensive products
-- Question : What are the 10 highest-priced products by MSRP?
-- Skills   : ORDER BY, LIMIT
SELECT productCode, productName, productLine, MSRP
FROM products
ORDER BY MSRP DESC, productCode
LIMIT 10;

-- [B08] 5 cheapest products
-- Question : What are the 5 cheapest products to buy?
-- Skills   : ORDER BY, LIMIT
SELECT productCode, productName, productLine, buyPrice
FROM products
ORDER BY buyPrice ASC, productCode
LIMIT 5;

-- ---------- B2. Product lines ---------------------------------------

-- [B09] Products per line
-- Question : How many products are in each product line?
-- Skills   : GROUP BY, COUNT, ORDER BY
SELECT productLine, COUNT(*) AS total_products
FROM products
GROUP BY productLine
ORDER BY total_products DESC, productLine;

-- [B10] Average prices per line
-- Question : What are the average buy price and average MSRP of each product line?
-- Skills   : GROUP BY, AVG, ROUND
SELECT productLine,
       ROUND(AVG(buyPrice), 2) AS avg_buy_price,
       ROUND(AVG(MSRP), 2)     AS avg_msrp
FROM products
GROUP BY productLine
ORDER BY avg_msrp DESC;

-- [B11] Premium lines
-- Question : Which product lines have an average MSRP above 100?
-- Skills   : GROUP BY, HAVING, AVG
SELECT productLine, ROUND(AVG(MSRP), 2) AS avg_msrp
FROM products
GROUP BY productLine
HAVING AVG(MSRP) > 100
ORDER BY avg_msrp DESC;

-- [B12] Price range per line
-- Question : What are the lowest MSRP, highest MSRP and price spread of every product line?
-- Skills   : GROUP BY, MIN, MAX
SELECT productLine,
       MIN(MSRP)            AS lowest_msrp,
       MAX(MSRP)            AS highest_msrp,
       MAX(MSRP) - MIN(MSRP) AS price_spread
FROM products
GROUP BY productLine
ORDER BY price_spread DESC;

-- ---------- B3. Stock levels ----------------------------------------

-- [B13] Low stock
-- Question : Which products have fewer than 500 units in stock? Show the 25 lowest.
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT productCode, productName, productLine, quantityInStock
FROM products
WHERE quantityInStock < 500
ORDER BY quantityInStock ASC, productName
LIMIT 25;

-- [B14] Critical stock by line
-- Question : How many products per line have fewer than 100 units in stock?
-- Skills   : WHERE, GROUP BY, COUNT
SELECT productLine, COUNT(*) AS critical_products
FROM products
WHERE quantityInStock < 100
GROUP BY productLine
ORDER BY critical_products DESC, productLine;

-- [B15] Total stock per line
-- Question : How many units are in stock for each product line?
-- Skills   : GROUP BY, SUM
SELECT productLine, SUM(quantityInStock) AS units_in_stock
FROM products
GROUP BY productLine
ORDER BY units_in_stock DESC;

-- [B16] Lines with big inventory
-- Question : Which product lines hold more than 300,000 units in stock?
-- Skills   : GROUP BY, HAVING, SUM
SELECT productLine, SUM(quantityInStock) AS units_in_stock
FROM products
GROUP BY productLine
HAVING SUM(quantityInStock) > 300000
ORDER BY units_in_stock DESC;

-- [B17] Healthy stock band
-- Question : List products with between 5,000 and 9,000 units in stock, largest stock first (first 20).
-- Skills   : WHERE, BETWEEN, ORDER BY, LIMIT
SELECT productName, productLine, quantityInStock
FROM products
WHERE quantityInStock BETWEEN 5000 AND 9000
ORDER BY quantityInStock DESC, productName
LIMIT 20;

-- [B18] Overstocked products
-- Question : Which 15 products have more than 9,000 units in stock?
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT productName, productLine, quantityInStock
FROM products
WHERE quantityInStock > 9000
ORDER BY quantityInStock DESC, productName
LIMIT 15;

-- ---------- B4. Product searches ------------------------------------

-- [B19] Name contains 'Ford'
-- Question : Find all products with 'Ford' in the name.
-- Skills   : LIKE '%Ford%', ORDER BY
SELECT productCode, productName, productLine, MSRP
FROM products
WHERE productName LIKE '%Ford%'
ORDER BY productName
LIMIT 25;

-- [B20] Name starts with '1969'
-- Question : Find all products whose name starts with '1969'.
-- Skills   : LIKE '1969%', ORDER BY
SELECT productCode, productName, productLine, MSRP
FROM products
WHERE productName LIKE '1969%'
ORDER BY productName;

-- [B21] Description search
-- Question : Find classic or vintage cars whose description mentions 'opening doors' (first 15).
-- Skills   : LIKE on a text column, AND, IN
SELECT productName, productLine, productScale
FROM products
WHERE productDescription LIKE '%opening doors%'
  AND productLine IN ('Classic Cars', 'Vintage Cars')
ORDER BY productName
LIMIT 15;

-- [B22] Vendor search
-- Question : How many products come from vendors whose name contains 'Diecast'? Break it down by vendor.
-- Skills   : LIKE, GROUP BY, COUNT
SELECT productVendor, COUNT(*) AS total_products
FROM products
WHERE productVendor LIKE '%Diecast%'
GROUP BY productVendor
ORDER BY total_products DESC, productVendor;

-- [B23] Biggest vendors
-- Question : Which vendors supply more than 25 products?
-- Skills   : GROUP BY, HAVING
SELECT productVendor, COUNT(*) AS total_products
FROM products
GROUP BY productVendor
HAVING COUNT(*) > 25
ORDER BY total_products DESC, productVendor;

-- [B24] Scale filter
-- Question : Show 1:18 scale models in the Classic Cars and Vintage Cars lines, cheapest first (first 20).
-- Skills   : WHERE, AND, IN, ORDER BY, LIMIT
SELECT productName, productLine, productScale, MSRP
FROM products
WHERE productScale = '1:18'
  AND productLine IN ('Classic Cars', 'Vintage Cars')
ORDER BY MSRP ASC, productName
LIMIT 20;

-- ---------- B5. Product sorting & margins ---------------------------

-- [B25] Multi-column sort
-- Question : Sort products by product line (A-Z), then MSRP (high to low), then name (first 30).
-- Skills   : ORDER BY (three keys), LIMIT
SELECT productLine, productName, MSRP
FROM products
ORDER BY productLine ASC, MSRP DESC, productName ASC
LIMIT 30;

-- [B26] Best margins
-- Question : Which 10 products earn the biggest absolute margin (MSRP - buy price)? Show the mark-up percentage too.
-- Skills   : calculated columns, ROUND, ORDER BY, LIMIT
SELECT productName, productLine, buyPrice, MSRP,
       ROUND(MSRP - buyPrice, 2)                     AS margin,
       ROUND((MSRP - buyPrice) * 100.0 / buyPrice, 1) AS markup_pct
FROM products
ORDER BY margin DESC, productName
LIMIT 10;

-- [B27] Above-average price
-- Question : How many products have an MSRP above the catalogue average, and what is that average?
-- Skills   : subquery in WHERE and in SELECT
SELECT COUNT(*) AS products_above_average,
       (SELECT ROUND(AVG(MSRP), 2) FROM products) AS catalogue_avg_msrp
FROM products
WHERE MSRP > (SELECT AVG(MSRP) FROM products);

-- [B28] Most expensive product in each line
-- Question : What is the highest-priced product in each product line?
-- Skills   : correlated subquery, MAX
SELECT productLine, productName, MSRP
FROM products p1
WHERE MSRP = (SELECT MAX(MSRP)
              FROM products p2
              WHERE p2.productLine = p1.productLine)
ORDER BY productLine;

-- [B29] Products never ordered
-- Question : Which products have never been ordered? (first 20)
-- Skills   : NOT IN subquery, ORDER BY, LIMIT
SELECT productCode, productName, productLine, quantityInStock
FROM products
WHERE productCode NOT IN (SELECT productCode FROM orderdetails)
ORDER BY productLine, productName
LIMIT 20;

-- [B30] Best sellers
-- Question : What are the 10 best-selling products by total units ordered?
-- Skills   : GROUP BY, SUM, subquery in SELECT, ORDER BY, LIMIT
SELECT od.productCode,
       (SELECT p.productName FROM products p WHERE p.productCode = od.productCode) AS productName,
       SUM(od.quantityOrdered) AS units_sold
FROM orderdetails od
GROUP BY od.productCode
ORDER BY units_sold DESC, od.productCode
LIMIT 10;

-- [B31] Pagination - page 5
-- Question : Products are listed 20 per page in alphabetical order. Show page 5.
-- Skills   : ORDER BY, LIMIT, OFFSET
SELECT productCode, productName, productLine, MSRP
FROM products
ORDER BY productName
LIMIT 20 OFFSET 80;

-- [B32] Product with the most stock
-- Question : Which product has the highest quantity in stock?
-- Skills   : subquery with MAX
SELECT productCode, productName, productLine, quantityInStock
FROM products
WHERE quantityInStock = (SELECT MAX(quantityInStock) FROM products);

-- [B33] Above the average of its own line
-- Question : Which products are priced above the average MSRP of their own product line? (first 15 by MSRP)
-- Skills   : correlated subquery, AVG
SELECT productName, productLine, MSRP
FROM products p1
WHERE MSRP > (SELECT AVG(MSRP)
              FROM products p2
              WHERE p2.productLine = p1.productLine)
ORDER BY MSRP DESC, productName
LIMIT 15;


-- #####################################################################
--  SECTION C - PAYMENT ANALYSIS
-- #####################################################################

-- ---------- C1. Payment dates ---------------------------------------

-- [C01] Latest payments
-- Question : Show the 20 most recent payments.
-- Skills   : ORDER BY, LIMIT
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
ORDER BY paymentDate DESC, amount DESC
LIMIT 20;

-- [C02] Payments in 2025
-- Question : Which were the 20 largest payments received during 2025?
-- Skills   : WHERE, BETWEEN (dates), ORDER BY, LIMIT
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE paymentDate BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY amount DESC, paymentDate
LIMIT 20;

-- [C03] Q4 2025 cash-in
-- Question : How many payments were received in Q4 2025 and what was their total?
-- Skills   : WHERE, BETWEEN, COUNT, SUM
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
WHERE paymentDate BETWEEN '2025-10-01' AND '2025-12-31';

-- [C04] A specific month
-- Question : How many payments arrived in March 2026 and what was their total?
-- Skills   : WHERE with YEAR() and MONTH(), COUNT, SUM
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
WHERE YEAR(paymentDate) = 2026
  AND MONTH(paymentDate) = 3;

-- [C05] Payments per year
-- Question : How many payments were received each year and how much money did they bring in?
-- Skills   : GROUP BY YEAR(), COUNT, SUM
SELECT YEAR(paymentDate)     AS pay_year,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
GROUP BY YEAR(paymentDate)
ORDER BY pay_year;

-- [C06] Payments per month in 2025
-- Question : Break 2025 down by month: payment count and total received.
-- Skills   : WHERE, GROUP BY MONTH(), COUNT, SUM
SELECT MONTH(paymentDate)    AS pay_month,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
WHERE YEAR(paymentDate) = 2025
GROUP BY MONTH(paymentDate)
ORDER BY pay_month;

-- [C07] Busiest payment months
-- Question : Which 5 calendar months (year + month) saw the most payments?
-- Skills   : GROUP BY (two expressions), COUNT, ORDER BY, LIMIT
SELECT YEAR(paymentDate)  AS pay_year,
       MONTH(paymentDate) AS pay_month,
       COUNT(*)           AS payments_made
FROM payments
GROUP BY YEAR(paymentDate), MONTH(paymentDate)
ORDER BY payments_made DESC, pay_year DESC, pay_month DESC
LIMIT 5;

-- [C08] First and last payment
-- Question : When was the first payment received and when was the most recent one?
-- Skills   : MIN, MAX on dates
SELECT MIN(paymentDate) AS first_payment,
       MAX(paymentDate) AS latest_payment
FROM payments;

-- [C09] Payments before 2024
-- Question : How many payments were received before 2024? (i.e. the year is NOT 2024, 2025 or 2026)
-- Skills   : WHERE, NOT IN, COUNT
SELECT COUNT(*) AS payments_before_2024
FROM payments
WHERE YEAR(paymentDate) NOT IN (2024, 2025, 2026);

-- [C10] Best payment days
-- Question : On which 5 dates did we receive the most money in total?
-- Skills   : GROUP BY, SUM, ORDER BY, LIMIT
SELECT paymentDate,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
GROUP BY paymentDate
ORDER BY total_received DESC
LIMIT 5;

-- ---------- C2. Payment counts & customer activity ------------------

-- [C11] Most active payers
-- Question : Which 10 customers have made the most payments?
-- Skills   : GROUP BY, COUNT, ORDER BY, LIMIT
SELECT customerNumber, COUNT(*) AS payments_made
FROM payments
GROUP BY customerNumber
ORDER BY payments_made DESC, customerNumber
LIMIT 10;

-- [C12] Frequent payers
-- Question : Which customers have made more than 20 payments? (top 15)
-- Skills   : GROUP BY, HAVING, COUNT, LIMIT
SELECT customerNumber, COUNT(*) AS payments_made
FROM payments
GROUP BY customerNumber
HAVING COUNT(*) > 20
ORDER BY payments_made DESC, customerNumber
LIMIT 15;

-- [C13] One-time payers
-- Question : How many customers have made exactly one payment?
-- Skills   : derived table (subquery in FROM), HAVING, COUNT
SELECT COUNT(*) AS customers_with_one_payment
FROM (SELECT customerNumber
      FROM payments
      GROUP BY customerNumber
      HAVING COUNT(*) = 1) AS single_payment;

-- [C14] Payers above the typical frequency
-- Question : Which customers have made more payments than the average number of payments per paying customer? (top 10)
-- Skills   : HAVING with a subquery
SELECT customerNumber, COUNT(*) AS payments_made
FROM payments
GROUP BY customerNumber
HAVING COUNT(*) > (SELECT COUNT(*) * 1.0 / COUNT(DISTINCT customerNumber) FROM payments)
ORDER BY payments_made DESC, customerNumber
LIMIT 10;

-- [C15] Customers who paid in 2024 and 2025
-- Question : How many customers made at least one payment in 2024 AND at least one in 2025?
-- Skills   : IN with two subqueries, COUNT
SELECT COUNT(*) AS customers_paying_both_years
FROM customers
WHERE customerNumber IN (SELECT customerNumber FROM payments WHERE YEAR(paymentDate) = 2024)
  AND customerNumber IN (SELECT customerNumber FROM payments WHERE YEAR(paymentDate) = 2025);

-- [C16] Japanese customers' payments
-- Question : How much have customers from Japan paid in total?
-- Skills   : IN subquery, SUM, COUNT
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_paid
FROM payments
WHERE customerNumber IN (SELECT customerNumber FROM customers WHERE country = 'Japan');

-- [C17] Check number search
-- Question : How many payments have a check number starting with 'H'?
-- Skills   : LIKE 'H%', COUNT
SELECT COUNT(*) AS payments_with_H_check
FROM payments
WHERE checkNumber LIKE 'H%';

-- ---------- C3. Total payments per customer -------------------------

-- [C18] Top 10 customers by total paid
-- Question : Who are the 10 customers that have paid us the most in total?
-- Skills   : GROUP BY, SUM, COUNT, subquery in SELECT, ORDER BY, LIMIT
SELECT p.customerNumber,
       (SELECT c.customerName FROM customers c WHERE c.customerNumber = p.customerNumber) AS customerName,
       COUNT(*)              AS payments_made,
       ROUND(SUM(p.amount), 2) AS total_paid
FROM payments p
GROUP BY p.customerNumber
ORDER BY total_paid DESC
LIMIT 10;

-- [C19] Customers with low lifetime payments
-- Question : Which customers have paid less than 5,000 in total? (15 lowest)
-- Skills   : GROUP BY, HAVING, SUM
SELECT customerNumber, ROUND(SUM(amount), 2) AS total_paid
FROM payments
GROUP BY customerNumber
HAVING SUM(amount) < 5000
ORDER BY total_paid ASC
LIMIT 15;

-- [C20] High average payers
-- Question : Which customers pay more than 25,000 on average per payment? (top 15)
-- Skills   : GROUP BY, HAVING AVG, ORDER BY, LIMIT
SELECT customerNumber,
       COUNT(*)                AS payments_made,
       ROUND(AVG(amount), 2)   AS avg_payment
FROM payments
GROUP BY customerNumber
HAVING AVG(amount) > 25000
ORDER BY avg_payment DESC
LIMIT 15;

-- ---------- C4. Total / average / min / max -------------------------

-- [C21] Total payments received
-- Question : What is the total amount of all payments and how many payments were made?
-- Skills   : SUM, COUNT
SELECT COUNT(*)              AS total_payments,
       ROUND(SUM(amount), 2) AS total_amount
FROM payments;

-- [C22] Average payment
-- Question : What is the average payment amount?
-- Skills   : AVG, ROUND
SELECT ROUND(AVG(amount), 2) AS average_payment
FROM payments;

-- [C23] Smallest and largest payment
-- Question : What are the minimum and maximum payment amounts?
-- Skills   : MIN, MAX
SELECT MIN(amount) AS min_payment,
       MAX(amount) AS max_payment
FROM payments;

-- [C24] Payment summary in one row
-- Question : Give a one-row payment summary: count, total, average, minimum and maximum.
-- Skills   : COUNT, SUM, AVG, MIN, MAX
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount,
       MIN(amount)           AS min_amount,
       MAX(amount)           AS max_amount
FROM payments;

-- [C25] Payments over 50,000
-- Question : List payments above 50,000, largest first (top 20).
-- Skills   : WHERE, ORDER BY, LIMIT
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 50000
ORDER BY amount DESC
LIMIT 20;

-- [C26] Payment band
-- Question : How many payments were between 10,000 and 20,000 and how much did they total?
-- Skills   : BETWEEN, COUNT, SUM
SELECT COUNT(*)              AS payments_in_band,
       ROUND(SUM(amount), 2) AS band_total
FROM payments
WHERE amount BETWEEN 10000 AND 20000;

-- [C27] Above-average payments
-- Question : How many payments are larger than the average payment?
-- Skills   : subquery in WHERE, COUNT
SELECT COUNT(*) AS above_average_payments
FROM payments
WHERE amount > (SELECT AVG(amount) FROM payments);

-- [C28] The largest payment ever
-- Question : Who made the single largest payment, when, and how much?
-- Skills   : subquery with MAX, subquery in SELECT
SELECT p.customerNumber,
       (SELECT c.customerName FROM customers c WHERE c.customerNumber = p.customerNumber) AS customerName,
       p.paymentDate,
       p.amount
FROM payments p
WHERE p.amount = (SELECT MAX(amount) FROM payments);

-- [C29] The smallest payment ever
-- Question : Who made the single smallest payment, when, and how much?
-- Skills   : subquery with MIN
SELECT p.customerNumber,
       (SELECT c.customerName FROM customers c WHERE c.customerNumber = p.customerNumber) AS customerName,
       p.paymentDate,
       p.amount
FROM payments p
WHERE p.amount = (SELECT MIN(amount) FROM payments);

-- [C30] Pagination - page 2
-- Question : Payments are shown 25 per page, newest first. Show page 2.
-- Skills   : ORDER BY, LIMIT, OFFSET
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
ORDER BY paymentDate DESC, customerNumber, checkNumber
LIMIT 25 OFFSET 25;

-- [C31] Very large payments
-- Question : Which customers have made at least one payment over 45,000? Show how many such payments they made.
-- Skills   : WHERE, GROUP BY, COUNT, ORDER BY, LIMIT
SELECT customerNumber, COUNT(*) AS payments_over_45k, MAX(amount) AS largest_payment
FROM payments
WHERE amount > 45000
GROUP BY customerNumber
ORDER BY payments_over_45k DESC, largest_payment DESC
LIMIT 15;


-- #####################################################################
--  SECTION D - BONUS: JOINs AND BUSINESS INSIGHTS  (optional)
--  These go beyond the skills list in the brief.
-- #####################################################################

-- [D01] Payments by country
-- Question : How much has each country paid in total? (JOIN customers to payments)
-- Skills   : INNER JOIN, GROUP BY, SUM, COUNT
SELECT c.country,
       COUNT(p.checkNumber)    AS payments_made,
       ROUND(SUM(p.amount), 2) AS total_paid
FROM customers c
JOIN payments p ON p.customerNumber = c.customerNumber
GROUP BY c.country
ORDER BY total_paid DESC;

-- [D02] Top 10 customers with their sales rep
-- Question : Show the 10 biggest paying customers together with the name of their sales rep.
-- Skills   : multi-table JOIN, GROUP BY, SUM
SELECT c.customerName,
       c.country,
       e.firstName AS rep_first_name,
       e.lastName  AS rep_last_name,
       ROUND(SUM(p.amount), 2) AS total_paid
FROM customers c
JOIN payments  p ON p.customerNumber = c.customerNumber
JOIN employees e ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY c.customerNumber, c.customerName, c.country, e.firstName, e.lastName
ORDER BY total_paid DESC
LIMIT 10;

-- [D03] Revenue by product line
-- Question : How many units did each product line sell and what revenue did it generate (excluding cancelled orders)?
-- Skills   : JOIN, SUM of a calculated column, GROUP BY
SELECT pr.productLine,
       SUM(od.quantityOrdered)                        AS units_sold,
       ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM orderdetails od
JOIN products pr ON pr.productCode = od.productCode
JOIN orders   o  ON o.orderNumber  = od.orderNumber
WHERE o.status <> 'Cancelled'
GROUP BY pr.productLine
ORDER BY revenue DESC;

-- [D04] Sales rep performance
-- Question : Which 10 sales reps have collected the most payments from their customers?
-- Skills   : JOIN, GROUP BY, SUM, COUNT DISTINCT
SELECT e.employeeNumber,
       e.firstName,
       e.lastName,
       COUNT(DISTINCT c.customerNumber) AS paying_customers,
       ROUND(SUM(p.amount), 2)          AS total_collected
FROM employees e
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN payments  p ON p.customerNumber         = c.customerNumber
GROUP BY e.employeeNumber, e.firstName, e.lastName
ORDER BY total_collected DESC
LIMIT 10;

-- [D05] Late shipments
-- Question : How many orders were shipped after their required date, and what share of all shipped orders is that?
-- Skills   : WHERE comparing two columns, COUNT, subquery
SELECT COUNT(*) AS late_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE shippedDate IS NOT NULL), 2) AS pct_of_shipped
FROM orders
WHERE shippedDate > requiredDate;

-- [D06] Largest orders
-- Question : What are the 10 highest-value orders?
-- Skills   : GROUP BY, SUM of a calculated column, ORDER BY, LIMIT
SELECT orderNumber,
       COUNT(*)                                       AS line_items,
       ROUND(SUM(quantityOrdered * priceEach), 2)     AS order_value
FROM orderdetails
GROUP BY orderNumber
ORDER BY order_value DESC
LIMIT 10;

-- [D07] Yearly revenue trend
-- Question : What was the order revenue in each year (excluding cancelled orders)?
-- Skills   : JOIN, YEAR(), GROUP BY, SUM
SELECT YEAR(o.orderDate) AS order_year,
       COUNT(DISTINCT o.orderNumber)                    AS orders_placed,
       ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM orders o
JOIN orderdetails od ON od.orderNumber = o.orderNumber
WHERE o.status <> 'Cancelled'
GROUP BY YEAR(o.orderDate)
ORDER BY order_year;

-- [D08] Payment size buckets
-- Question : Group all payments into size buckets (under 5k, 5k-15k, 15k-30k, over 30k) and count them.
-- Skills   : CASE, GROUP BY, COUNT, SUM
SELECT CASE
         WHEN amount < 5000  THEN '1) under 5,000'
         WHEN amount < 15000 THEN '2) 5,000 - 14,999'
         WHEN amount < 30000 THEN '3) 15,000 - 29,999'
         ELSE                     '4) 30,000 and over'
       END AS payment_bucket,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS bucket_total
FROM payments
GROUP BY CASE
         WHEN amount < 5000  THEN '1) under 5,000'
         WHEN amount < 15000 THEN '2) 5,000 - 14,999'
         WHEN amount < 30000 THEN '3) 15,000 - 29,999'
         ELSE                     '4) 30,000 and over'
       END
ORDER BY payment_bucket;
