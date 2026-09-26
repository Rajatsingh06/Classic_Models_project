# ClassicModels Query Challenge - Query Results

Output of every query in `sql/03_queries.sql`, executed on the bundled dataset (`sqlite/classicmodels.db`). Each table shows at most the first 10 rows; the row count is the full size of the result.


---

## Section A - Customer Analysis

### A01 - List customer locations

**Question:** Show the name, city, state and country of every customer, sorted by country, then city, then name. Display the first 25 rows.  
**Skills:** SELECT, ORDER BY, LIMIT

```sql
SELECT customerName, city, state, country
FROM customers
ORDER BY country, city, customerName
LIMIT 25;
```

| customerName | city | state | country |
|---|---|---|---|
| Amica Designs & Co. | Adelaide | SA | Australia |
| Baroque Toys Pty | Adelaide | SA | Australia |
| Cambridge Hobbies Pty | Adelaide | SA | Australia |
| Delta Gift Ideas & Co. | Adelaide | SA | Australia |
| Delta Souvenirs & Co. | Adelaide | SA | Australia |
| Diecast Miniatures Pty Ltd | Adelaide | SA | Australia |
| Dragon Toys Pty Ltd | Adelaide | SA | Australia |
| Driftwood Hobbies Pty Ltd | Adelaide | SA | Australia |
| Enthusiast Distributors Pty | Adelaide | SA | Australia |
| Frontier Gift Shop & Co. | Adelaide | SA | Australia |

*25 row(s) returned (showing first 10).*

### A02 - Customers in the USA

**Question:** Which customers are located in the USA? Sort them by state and city (first 25).  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, city, state
FROM customers
WHERE country = 'USA'
ORDER BY state, city, customerName
LIMIT 25;
```

| customerNumber | customerName | city | state |
|---|---|---|---|
| 135 | Alpine Scale Models & Sons | Phoenix | AZ |
| 1797 | Anchor Classics & Sons | Phoenix | AZ |
| 658 | Baroque Gallery LLC | Phoenix | AZ |
| 1509 | Cambridge Souvenirs & Sons | Phoenix | AZ |
| 1879 | Cobalt Distributors & Sons | Phoenix | AZ |
| 1671 | Corporate Imports Co. | Phoenix | AZ |
| 1030 | Diecast Gift Ideas LLC | Phoenix | AZ |
| 480 | Diecast Hobby House Group | Phoenix | AZ |
| 2222 | Driftwood Toy Store Group | Phoenix | AZ |
| 1489 | Euro Models Inc. | Phoenix | AZ |

*25 row(s) returned (showing first 10).*

### A03 - Customers in France, Germany or Spain

**Question:** List customers based in France, Germany or Spain, sorted by country then name (first 25).  
**Skills:** WHERE, IN, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, city, country
FROM customers
WHERE country IN ('France', 'Germany', 'Spain')
ORDER BY country, customerName
LIMIT 25;
```

| customerNumber | customerName | city | country |
|---|---|---|---|
| 859 | Alpine Collectables SARL | Lille | France |
| 1164 | Alpine Merchants et Fils | Strasbourg | France |
| 1785 | Alpine Merchants SA | Lyon | France |
| 1542 | Alpine Miniatures et Fils | Paris | France |
| 451 | Alpine Models SARL | Paris | France |
| 582 | Alpine Showroom et Fils | Bordeaux | France |
| 171 | Amica Auto Models SA | Strasbourg | France |
| 2182 | Amica Collectibles SARL | Paris | France |
| 589 | Amica Gift Shop SA | Toulouse | France |
| 1831 | Anchor Classics et Fils | Reims | France |

*25 row(s) returned (showing first 10).*

### A04 - Customers outside North America

**Question:** How many customers are located outside the USA and Canada?  
**Skills:** WHERE, NOT IN, COUNT

```sql
SELECT COUNT(*) AS customers_outside_usa_canada
FROM customers
WHERE country NOT IN ('USA', 'Canada');
```

| customers_outside_usa_canada |
|---|
| 1782 |

*1 row(s) returned.*

### A05 - Countries we sell to

**Question:** Which distinct countries do our customers come from?  
**Skills:** SELECT DISTINCT, ORDER BY

```sql
SELECT DISTINCT country
FROM customers
ORDER BY country;
```

| country |
|---|
| Australia |
| Austria |
| Belgium |
| Canada |
| Denmark |
| Finland |
| France |
| Germany |
| Hong Kong |
| India |

*23 row(s) returned (showing first 10).*

### A06 - Customers per country

**Question:** How many customers does each country have? Show the biggest markets first.  
**Skills:** GROUP BY, COUNT, ORDER BY

```sql
SELECT country, COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC, country;
```

| country | total_customers |
|---|---|
| USA | 613 |
| Japan | 214 |
| France | 200 |
| Germany | 165 |
| UK | 152 |
| Spain | 144 |
| Italy | 139 |
| Australia | 129 |
| Canada | 105 |
| India | 85 |

*23 row(s) returned (showing first 10).*

### A07 - Major customer countries

**Question:** Which countries have at least 100 customers?  
**Skills:** GROUP BY, HAVING, COUNT

```sql
SELECT country, COUNT(*) AS total_customers
FROM customers
GROUP BY country
HAVING COUNT(*) >= 100
ORDER BY total_customers DESC;
```

| country | total_customers |
|---|---|
| USA | 613 |
| Japan | 214 |
| France | 200 |
| Germany | 165 |
| UK | 152 |
| Spain | 144 |
| Italy | 139 |
| Australia | 129 |
| Canada | 105 |

*9 row(s) returned.*

### A08 - Customer-heavy cities

**Question:** Which cities have more than 20 customers? Show the top 15.  
**Skills:** GROUP BY (two columns), HAVING, LIMIT

```sql
SELECT city, country, COUNT(*) AS total_customers
FROM customers
GROUP BY city, country
HAVING COUNT(*) > 20
ORDER BY total_customers DESC, city
LIMIT 15;
```

| city | country | total_customers |
|---|---|---|
| Singapore | Singapore | 63 |
| Nagoya | Japan | 51 |
| Sapporo | Japan | 42 |
| Atlanta | USA | 39 |
| San Francisco | USA | 39 |
| Yokohama | Japan | 37 |
| Seville | Spain | 36 |
| Tokyo | Japan | 36 |
| Hong Kong | Hong Kong | 35 |
| Birmingham | UK | 34 |

*15 row(s) returned (showing first 10).*

### A09 - Customers with no state recorded

**Question:** For each country, how many customers have no state on file? Show the top 10 countries.  
**Skills:** WHERE ... IS NULL, GROUP BY, LIMIT

```sql
SELECT country, COUNT(*) AS customers_without_state
FROM customers
WHERE state IS NULL
GROUP BY country
ORDER BY customers_without_state DESC, country
LIMIT 10;
```

| country | customers_without_state |
|---|---|
| Japan | 214 |
| France | 200 |
| Germany | 165 |
| UK | 152 |
| Spain | 144 |
| Italy | 139 |
| Singapore | 63 |
| Denmark | 52 |
| Belgium | 51 |
| Netherlands | 49 |

*10 row(s) returned.*

### A10 - Very high credit limits

**Question:** Which customers have a credit limit of 200,000 or more? Show the top 20.  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE creditLimit >= 200000
ORDER BY creditLimit DESC, customerName
LIMIT 20;
```

| customerNumber | customerName | country | creditLimit |
|---|---|---|---|
| 576 | Anchor Designs & Sons | India | 246,100.00 |
| 821 | Signal Collectibles Inc. | USA | 244,300.00 |
| 403 | Harbour Hobby House Cie | France | 244,200.00 |
| 303 | Corporate Hobbies Corp. | USA | 243,200.00 |
| 1646 | Amica Miniatures Inc. | USA | 242,900.00 |
| 1189 | Falcon Gifts GmbH | Germany | 240,400.00 |
| 2595 | Granite Showroom Inc. | USA | 240,300.00 |
| 1879 | Cobalt Distributors & Sons | USA | 240,000.00 |
| 631 | Rocket Imports Pty | Australia | 238,500.00 |
| 945 | Falcon Depot & Figli | Italy | 237,000.00 |

*20 row(s) returned (showing first 10).*

### A11 - Mid-range credit limits

**Question:** How many customers have a credit limit between 50,000 and 75,000 (inclusive)?  
**Skills:** WHERE, BETWEEN, COUNT

```sql
SELECT COUNT(*) AS customers_in_range
FROM customers
WHERE creditLimit BETWEEN 50000 AND 75000;
```

| customers_in_range |
|---|
| 459 |

*1 row(s) returned.*

### A12 - Top 10 credit limits

**Question:** Who are the 10 customers with the highest credit limit?  
**Skills:** ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country, creditLimit
FROM customers
ORDER BY creditLimit DESC, customerNumber
LIMIT 10;
```

| customerNumber | customerName | country | creditLimit |
|---|---|---|---|
| 576 | Anchor Designs & Sons | India | 246,100.00 |
| 821 | Signal Collectibles Inc. | USA | 244,300.00 |
| 403 | Harbour Hobby House Cie | France | 244,200.00 |
| 303 | Corporate Hobbies Corp. | USA | 243,200.00 |
| 1646 | Amica Miniatures Inc. | USA | 242,900.00 |
| 1189 | Falcon Gifts GmbH | Germany | 240,400.00 |
| 2595 | Granite Showroom Inc. | USA | 240,300.00 |
| 1879 | Cobalt Distributors & Sons | USA | 240,000.00 |
| 631 | Rocket Imports Pty | Australia | 238,500.00 |
| 945 | Falcon Depot & Figli | Italy | 237,000.00 |

*10 row(s) returned.*

### A13 - Lowest non-zero credit limits

**Question:** Which 10 customers have the lowest credit limit above zero?  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE creditLimit > 0
ORDER BY creditLimit ASC, customerNumber
LIMIT 10;
```

| customerNumber | customerName | country | creditLimit |
|---|---|---|---|
| 411 | Prestige Gift Shop GmbH | Austria | 6,300.00 |
| 1791 | Mini Hobby House PLC | UK | 6,300.00 |
| 1382 | Prestige Models & Co. | Australia | 7,000.00 |
| 435 | Alpine Souvenirs Ltd | India | 7,300.00 |
| 439 | Corporate Scale Models PLC | UK | 7,300.00 |
| 2459 | Jade Gifts K.K. | Japan | 8,100.00 |
| 2210 | Oasis Hobbies Inc. | Philippines | 8,500.00 |
| 1322 | Horizon Miniatures B.V. | Netherlands | 8,900.00 |
| 1356 | Bluebird Hobby House Inc. | Canada | 9,000.00 |
| 1351 | Emerald Merchants & Co. | UK | 9,600.00 |

*10 row(s) returned.*

### A14 - Customers with no credit

**Question:** Which customers have a credit limit of zero? Show 15 alphabetically.  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country
FROM customers
WHERE creditLimit = 0
ORDER BY customerName
LIMIT 15;
```

| customerNumber | customerName | country |
|---|---|---|
| 2189 | Alpine Merchants & Co. KG | Germany |
| 1951 | Alpine Miniatures Pte Ltd | Singapore |
| 582 | Alpine Showroom et Fils | France |
| 818 | Alpine Toys & Co. KG | Germany |
| 1142 | Amica Boutique & Sons | USA |
| 1056 | Amica Gallery GmbH | Germany |
| 1590 | Amica Gifts K.K. | Japan |
| 465 | Amica Merchants S.L. | Spain |
| 1848 | Amica Miniatures Pte. | Singapore |
| 1831 | Anchor Classics et Fils | France |

*15 row(s) returned (showing first 10).*

### A15 - Credit limit statistics by country

**Question:** For each country show the number of customers and the average, minimum, maximum and total credit limit. Sort by average credit, highest first.  
**Skills:** GROUP BY, COUNT, AVG, MIN, MAX, SUM, ROUND

```sql
SELECT country,
       COUNT(*)                   AS customers,
       ROUND(AVG(creditLimit), 2) AS avg_credit,
       MIN(creditLimit)           AS min_credit,
       MAX(creditLimit)           AS max_credit,
       SUM(creditLimit)           AS total_credit
FROM customers
GROUP BY country
ORDER BY avg_credit DESC;
```

| country | customers | avg_credit | min_credit | max_credit | total_credit |
|---|---|---|---|---|---|
| New Zealand | 33 | 105,330.30 | 0.00 | 233,200.00 | 3,475,900.00 |
| Denmark | 52 | 104,696.15 | 0.00 | 214,000.00 | 5,444,200.00 |
| India | 85 | 104,684.71 | 0.00 | 246,100.00 | 8,898,200.00 |
| Finland | 47 | 103,125.53 | 0.00 | 216,900.00 | 4,846,900.00 |
| France | 200 | 96,971.00 | 0.00 | 244,200.00 | 19,394,200.00 |
| Germany | 165 | 96,592.12 | 0.00 | 240,400.00 | 15,937,700.00 |
| Italy | 139 | 96,326.62 | 0.00 | 237,000.00 | 13,389,400.00 |
| Hong Kong | 35 | 94,674.29 | 0.00 | 230,900.00 | 3,313,600.00 |
| Canada | 105 | 93,008.57 | 0.00 | 226,000.00 | 9,765,900.00 |
| Australia | 129 | 92,802.33 | 0.00 | 238,500.00 | 11,971,500.00 |

*23 row(s) returned (showing first 10).*

### A16 - Countries with above-average credit

**Question:** Which countries have an average credit limit higher than the average credit limit of all customers?  
**Skills:** GROUP BY, HAVING, subquery

```sql
SELECT country, ROUND(AVG(creditLimit), 2) AS avg_credit
FROM customers
GROUP BY country
HAVING AVG(creditLimit) > (SELECT AVG(creditLimit) FROM customers)
ORDER BY avg_credit DESC;
```

| country | avg_credit |
|---|---|
| New Zealand | 105,330.30 |
| Denmark | 104,696.15 |
| India | 104,684.71 |
| Finland | 103,125.53 |
| France | 96,971.00 |
| Germany | 96,592.12 |
| Italy | 96,326.62 |
| Hong Kong | 94,674.29 |
| Canada | 93,008.57 |
| Australia | 92,802.33 |

*10 row(s) returned.*

### A17 - Overall credit exposure

**Question:** What are the total, average, lowest and highest credit limits across all customers?  
**Skills:** SUM, AVG, MIN, MAX

```sql
SELECT SUM(creditLimit)           AS total_credit,
       ROUND(AVG(creditLimit), 2) AS avg_credit,
       MIN(creditLimit)           AS min_credit,
       MAX(creditLimit)           AS max_credit
FROM customers;
```

| total_credit | avg_credit | min_credit | max_credit |
|---|---|---|---|
| 231,129,700.00 | 92,451.88 | 0.00 | 246,100.00 |

*1 row(s) returned.*

### A18 - Names starting with 'A'

**Question:** Find customers whose name starts with the letter A (first 20).  
**Skills:** LIKE 'A%', ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country
FROM customers
WHERE customerName LIKE 'A%'
ORDER BY customerName
LIMIT 20;
```

| customerNumber | customerName | country |
|---|---|---|
| 592 | Alpine Auto Models Pvt Ltd | India |
| 2571 | Alpine Boutique Ltd | India |
| 1531 | Alpine Classics Group | USA |
| 819 | Alpine Collectables Group | USA |
| 452 | Alpine Collectables Ltd | India |
| 859 | Alpine Collectables SARL | France |
| 957 | Alpine Collectibles Ltd. | Canada |
| 2346 | Alpine Distributors AG | Germany |
| 978 | Alpine Gallery Ltd. | Japan |
| 1720 | Alpine Gallery y Hijos | Spain |

*20 row(s) returned (showing first 10).*

### A19 - Names containing 'Gift'

**Question:** Find customers with 'Gift' anywhere in their name (first 20).  
**Skills:** LIKE '%Gift%', ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country
FROM customers
WHERE customerName LIKE '%Gift%'
ORDER BY customerName
LIMIT 20;
```

| customerNumber | customerName | country |
|---|---|---|
| 1497 | Alpine Gift Ideas N.V. | Belgium |
| 2197 | Alpine Gift Shop Ltd | Ireland |
| 172 | Alpine Gifts & Co. KG | Germany |
| 843 | Alpine Gifts Pte Ltd | Singapore |
| 1944 | Alpine Gifts Pty | Australia |
| 174 | Alpine Gifts S.r.l. | Italy |
| 505 | Amica Gift Ideas ApS | Denmark |
| 1168 | Amica Gift Ideas B.V. | Netherlands |
| 589 | Amica Gift Shop SA | France |
| 1590 | Amica Gifts K.K. | Japan |

*20 row(s) returned (showing first 10).*

### A20 - Limited companies in the UK, Ireland or Australia

**Question:** Find customers whose name contains 'Ltd' and that are based in the UK, Ireland or Australia (first 20).  
**Skills:** LIKE, AND, IN, LIMIT

```sql
SELECT customerNumber, customerName, country
FROM customers
WHERE customerName LIKE '%Ltd%'
  AND country IN ('UK', 'Ireland', 'Australia')
ORDER BY country, customerName
LIMIT 20;
```

| customerNumber | customerName | country |
|---|---|---|
| 894 | Alpine Hobbies Pty Ltd | Australia |
| 1312 | Alpine Showroom Pty Ltd | Australia |
| 2228 | Anchor Merchants Pty Ltd | Australia |
| 871 | Anchor Toy Store Pty Ltd | Australia |
| 1147 | Beacon Distributors Pty Ltd | Australia |
| 2338 | Beacon Merchants Pty Ltd | Australia |
| 1202 | Cambridge Models Pty Ltd | Australia |
| 1709 | Classic Replicas Pty Ltd | Australia |
| 1888 | Cobalt Distributors Pty Ltd | Australia |
| 2122 | Corporate Imports Pty Ltd | Australia |

*20 row(s) returned (showing first 10).*

### A21 - Contact person search

**Question:** Find customers whose contact first name starts with 'Ma' and whose contact last name ends with 'son'.  
**Skills:** LIKE with two patterns, AND

```sql
SELECT customerNumber, customerName, contactFirstName, contactLastName
FROM customers
WHERE contactFirstName LIKE 'Ma%'
  AND contactLastName LIKE '%son'
ORDER BY contactLastName, contactFirstName, customerNumber
LIMIT 20;
```

| customerNumber | customerName | contactFirstName | contactLastName |
|---|---|---|---|
| 1553 | Harbour Gifts y Hijos | Maria | Anderson |
| 713 | Vintage Models Inc. | Marta | Anderson |
| 608 | Baroque Diecast Direct & Co. | Mason | Anderson |
| 168 | Alpine Miniatures Co. | Mateo | Anderson |
| 956 | Delta Hobbies y Hijos | Matthew | Anderson |
| 1379 | Signal Gallery & Sons | Maria | Jackson |
| 226 | Falcon Diecast Direct Ltd | Mason | Jackson |
| 2160 | Cambridge Models Ltd. | Marco | Johansson |
| 2462 | Northern Hobby House Inc. | Maria | Johansson |
| 158 | Beacon Classics & Sons | Marta | Johansson |

*20 row(s) returned (showing first 10).*

### A22 - Single-character wildcard

**Question:** Find customers whose name has 'a' as its second letter (first 15).  
**Skills:** LIKE '_a%', ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName
FROM customers
WHERE customerName LIKE '_a%'
ORDER BY customerName
LIMIT 15;
```

| customerNumber | customerName |
|---|---|
| 1447 | Baroque Auto Models Cie |
| 1642 | Baroque Auto Models Co. Ltd |
| 1536 | Baroque Classics SA |
| 392 | Baroque Collectables ASA |
| 1128 | Baroque Collectables Co. |
| 1481 | Baroque Collectables LLC |
| 1222 | Baroque Collectables SA |
| 431 | Baroque Collectibles Pty |
| 2108 | Baroque Designs Group |
| 1997 | Baroque Designs Teoranta |

*15 row(s) returned (showing first 10).*

### A23 - City search

**Question:** Find customers in cities starting with 'San ' and show how many customers each such city has.  
**Skills:** LIKE, GROUP BY, COUNT

```sql
SELECT city, country, COUNT(*) AS total_customers
FROM customers
WHERE city LIKE 'San %'
GROUP BY city, country
ORDER BY total_customers DESC;
```

| city | country | total_customers |
|---|---|---|
| San Francisco | USA | 39 |
| San Diego | USA | 34 |

*2 row(s) returned.*

### A24 - Customers of one sales rep

**Question:** List the customers assigned to sales rep 1010 (first 20, alphabetical).  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE salesRepEmployeeNumber = 1010
ORDER BY customerName
LIMIT 20;
```

| customerNumber | customerName | country | creditLimit |
|---|---|---|---|
| 153 | Amica Diecast Direct & Sons | USA | 133,100.00 |
| 1060 | Amica Gifts Ltd. | Canada | 132,100.00 |
| 2214 | Amica Hobbies Co. | USA | 168,300.00 |
| 1373 | Atelier Gift Ideas LLC | USA | 0.00 |
| 1760 | Beacon Emporium Co. | USA | 121,300.00 |
| 1305 | Bluebird Collectibles Co. | USA | 18,900.00 |
| 835 | Bluebird Toys Inc. | USA | 163,700.00 |
| 459 | Cambridge Collectables Inc. | USA | 137,500.00 |
| 1587 | Cedar Souvenirs Corp. | USA | 78,400.00 |
| 688 | Cedar Traders & Sons | USA | 28,500.00 |

*20 row(s) returned (showing first 10).*

### A25 - Customers per sales rep

**Question:** How many customers does each sales rep look after? Show the 10 largest portfolios.  
**Skills:** GROUP BY, COUNT, ORDER BY, LIMIT

```sql
SELECT salesRepEmployeeNumber, COUNT(*) AS total_customers
FROM customers
WHERE salesRepEmployeeNumber IS NOT NULL
GROUP BY salesRepEmployeeNumber
ORDER BY total_customers DESC, salesRepEmployeeNumber
LIMIT 10;
```

| salesRepEmployeeNumber | total_customers |
|---|---|
| 1027 | 167 |
| 1026 | 147 |
| 1030 | 142 |
| 1023 | 115 |
| 1033 | 103 |
| 1028 | 101 |
| 1024 | 98 |
| 1036 | 81 |
| 1009 | 78 |
| 1017 | 76 |

*10 row(s) returned.*

### A26 - Overloaded sales reps

**Question:** Which sales reps look after more than 100 customers?  
**Skills:** GROUP BY, HAVING

```sql
SELECT salesRepEmployeeNumber, COUNT(*) AS total_customers
FROM customers
WHERE salesRepEmployeeNumber IS NOT NULL
GROUP BY salesRepEmployeeNumber
HAVING COUNT(*) > 100
ORDER BY total_customers DESC;
```

| salesRepEmployeeNumber | total_customers |
|---|---|
| 1027 | 167 |
| 1026 | 147 |
| 1030 | 142 |
| 1023 | 115 |
| 1033 | 103 |
| 1028 | 101 |

*6 row(s) returned.*

### A27 - Customers without a sales rep

**Question:** Which customers have no sales rep assigned? (first 20)  
**Skills:** WHERE ... IS NULL, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country
FROM customers
WHERE salesRepEmployeeNumber IS NULL
ORDER BY country, customerName
LIMIT 20;
```

| customerNumber | customerName | country |
|---|---|---|
| 894 | Alpine Hobbies Pty Ltd | Australia |
| 1040 | Euro Hobby House & Co. | Australia |
| 1816 | Harbour Gallery Pty | Australia |
| 1209 | Heritage Distributors Pty | Australia |
| 1467 | Imperial Collectables & Co. | Australia |
| 1974 | Lakeside Diecast Direct & Co. | Australia |
| 1386 | Sunset Diecast Direct Pty Ltd | Australia |
| 2118 | Mini Classics GmbH | Austria |
| 1497 | Alpine Gift Ideas N.V. | Belgium |
| 1199 | Sunset Showroom S.A. | Belgium |

*20 row(s) returned (showing first 10).*

### A28 - Customers of the busiest sales rep

**Question:** List customers (first 20) of the sales rep who manages the most customers.  
**Skills:** subquery in WHERE, GROUP BY, ORDER BY, LIMIT

```sql
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
```

| customerNumber | customerName | country |
|---|---|---|
| 2197 | Alpine Gift Shop Ltd | Ireland |
| 2189 | Alpine Merchants & Co. KG | Germany |
| 1088 | Alpine Toys S.p.A. | Italy |
| 1805 | Alpine Wheels AB | Sweden |
| 465 | Amica Merchants S.L. | Spain |
| 2505 | Anchor Classics Teoranta | Ireland |
| 812 | Anchor Collectables SA | France |
| 2128 | Anchor Gallery PLC | UK |
| 529 | Anchor Scale Models Ltd | UK |
| 2373 | Anchor Souvenirs Ltd | UK |

*20 row(s) returned (showing first 10).*

### A29 - Sales reps with no customers

**Question:** Which sales reps have not been assigned any customers yet?  
**Skills:** NOT IN subquery, WHERE

```sql
SELECT employeeNumber, firstName, lastName, officeCode
FROM employees
WHERE jobTitle = 'Sales Rep'
  AND employeeNumber NOT IN (SELECT salesRepEmployeeNumber
                             FROM customers
                             WHERE salesRepEmployeeNumber IS NOT NULL);
```

| employeeNumber | firstName | lastName | officeCode |
|---|---|---|---|
| 1021 | Ingrid | Evans | 2 |
| 1035 | Sofia | Hoffmann | 7 |

*2 row(s) returned.*

### A30 - Reps serving Japan

**Question:** Which employees are the sales reps of Japanese customers?  
**Skills:** IN subquery

```sql
SELECT employeeNumber, firstName, lastName, jobTitle
FROM employees
WHERE employeeNumber IN (SELECT salesRepEmployeeNumber
                         FROM customers
                         WHERE country = 'Japan')
ORDER BY lastName;
```

| employeeNumber | firstName | lastName | jobTitle |
|---|---|---|---|
| 1045 | Jean | Anderson | Sales Rep |
| 1044 | Sakura | Brown | Sales Rep |
| 1047 | Carlos | Novak | Sales Rep |
| 1046 | Ananya | Reyes | Sales Rep |

*4 row(s) returned.*

### A31 - Above-average credit limit

**Question:** Which customers have a credit limit higher than the average? Show the top 20.  
**Skills:** subquery, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, creditLimit
FROM customers
WHERE creditLimit > (SELECT AVG(creditLimit) FROM customers)
ORDER BY creditLimit DESC, customerNumber
LIMIT 20;
```

| customerNumber | customerName | creditLimit |
|---|---|---|
| 576 | Anchor Designs & Sons | 246,100.00 |
| 821 | Signal Collectibles Inc. | 244,300.00 |
| 403 | Harbour Hobby House Cie | 244,200.00 |
| 303 | Corporate Hobbies Corp. | 243,200.00 |
| 1646 | Amica Miniatures Inc. | 242,900.00 |
| 1189 | Falcon Gifts GmbH | 240,400.00 |
| 2595 | Granite Showroom Inc. | 240,300.00 |
| 1879 | Cobalt Distributors & Sons | 240,000.00 |
| 631 | Rocket Imports Pty | 238,500.00 |
| 945 | Falcon Depot & Figli | 237,000.00 |

*20 row(s) returned (showing first 10).*

### A32 - Pagination - page 3

**Question:** Customers are shown 20 per page ordered by customer number. Show page 3.  
**Skills:** ORDER BY, LIMIT, OFFSET

```sql
SELECT customerNumber, customerName, city, country
FROM customers
ORDER BY customerNumber
LIMIT 20 OFFSET 40;
```

| customerNumber | customerName | city | country |
|---|---|---|---|
| 141 | Vintage Classics Group | Montreal | Canada |
| 142 | Amica Boutique Co., Ltd. | Tokyo | Japan |
| 143 | Marquee Auto Models & Figli | Rome | Italy |
| 144 | Atelier Gift Ideas ApS | Odense | Denmark |
| 145 | Iconic Merchants & Figli | Milan | Italy |
| 146 | Sunset Miniatures Pte. | Singapore | Singapore |
| 147 | Silver Classics Group | Seattle | USA |
| 148 | Crimson Merchants y Hijos | Seville | Spain |
| 149 | Cedar Depot AG | Munich | Germany |
| 150 | Heritage Gallery A/S | Odense | Denmark |

*20 row(s) returned (showing first 10).*

### A33 - Customers who never paid

**Question:** Which customers have never made a payment? Show the 20 with the highest credit limit.  
**Skills:** NOT IN subquery, ORDER BY, LIMIT

```sql
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE customerNumber NOT IN (SELECT customerNumber FROM payments)
ORDER BY creditLimit DESC, customerNumber
LIMIT 20;
```

| customerNumber | customerName | country | creditLimit |
|---|---|---|---|
| 631 | Rocket Imports Pty | Australia | 238,500.00 |
| 2086 | Imperial Classics & Sons | India | 236,400.00 |
| 2423 | Ivory Imports B.V. | Netherlands | 233,300.00 |
| 2115 | Xtreme Gallery LLC | USA | 231,500.00 |
| 453 | Horizon Gift Shop & Co. KG | Germany | 223,800.00 |
| 388 | Dragon Scale Models Pte. | Singapore | 218,700.00 |
| 1939 | Silver Souvenirs Group | USA | 216,600.00 |
| 383 | Kingdom Imports ASA | Norway | 216,000.00 |
| 2060 | Cobalt Depot & Sons | India | 211,500.00 |
| 2488 | Mini Showroom Ltd. | Japan | 209,600.00 |

*20 row(s) returned (showing first 10).*

### A34 - Customers who never ordered

**Question:** How many customers have never placed an order?  
**Skills:** NOT IN subquery, COUNT

```sql
SELECT COUNT(*) AS customers_without_orders
FROM customers
WHERE customerNumber NOT IN (SELECT customerNumber FROM orders);
```

| customers_without_orders |
|---|
| 282 |

*1 row(s) returned.*

### A35 - Big-spending customers

**Question:** Which customers have paid more than 400,000 in total? (first 20 by name)  
**Skills:** IN subquery with GROUP BY / HAVING / SUM

```sql
SELECT customerNumber, customerName, country
FROM customers
WHERE customerNumber IN (SELECT customerNumber
                         FROM payments
                         GROUP BY customerNumber
                         HAVING SUM(amount) > 400000)
ORDER BY customerName
LIMIT 20;
```

| customerNumber | customerName | country |
|---|---|---|
| 843 | Alpine Gifts Pte Ltd | Singapore |
| 1200 | Alpine Traders Group | USA |
| 1797 | Anchor Classics & Sons | USA |
| 1398 | Atelier Boutique K.K. | Japan |
| 1856 | Atelier Emporium & Co. | UK |
| 2294 | Baroque Scale Models & Co. | UK |
| 989 | Beacon Diecast Direct & Co. KG | Germany |
| 128 | Cambridge Models S.p.A. | Italy |
| 1048 | Classic Hobbies Group | USA |
| 629 | Cobalt Miniatures Oy | Finland |

*20 row(s) returned (showing first 10).*

### A36 - Highest credit limit in each country

**Question:** Which customer has the highest credit limit in each country?  
**Skills:** correlated subquery, MAX

```sql
SELECT country, customerName, creditLimit
FROM customers c1
WHERE creditLimit = (SELECT MAX(creditLimit)
                     FROM customers c2
                     WHERE c2.country = c1.country)
ORDER BY country, customerName;
```

| country | customerName | creditLimit |
|---|---|---|
| Australia | Rocket Imports Pty | 238,500.00 |
| Austria | Corporate Miniatures AG | 208,200.00 |
| Belgium | Beacon Diecast Direct S.A. | 230,900.00 |
| Canada | Xtreme Wheels Group | 226,000.00 |
| Denmark | Zenith Replicas ApS | 214,000.00 |
| Finland | Silver Toys Oy | 216,900.00 |
| France | Harbour Hobby House Cie | 244,200.00 |
| Germany | Falcon Gifts GmbH | 240,400.00 |
| Hong Kong | Diecast Replicas Co. Ltd | 230,900.00 |
| India | Anchor Designs & Sons | 246,100.00 |

*23 row(s) returned (showing first 10).*


---

## Section B - Product Analysis

### B01 - Product catalogue

**Question:** List the code, name, product line, buy price and MSRP of all products alphabetically (first 25).  
**Skills:** SELECT, ORDER BY, LIMIT

```sql
SELECT productCode, productName, productLine, buyPrice, MSRP
FROM products
ORDER BY productName
LIMIT 25;
```

| productCode | productName | productLine | buyPrice | MSRP |
|---|---|---|---|---|
| S24_2857 | 1904 Bentley 4.5 Litre Coupe - Premium Finish | Vintage Cars | 16.00 | 29.97 |
| S24_1889 | 1904 Daimler DE36 Fastback | Vintage Cars | 68.24 | 116.42 |
| S72_3518 | 1904 Lincoln Model K Tourer - Limited Run | Vintage Cars | 40.02 | 58.20 |
| S24_1032 | 1905 Bugatti Type 57 - Silver Edition | Vintage Cars | 74.81 | 133.21 |
| S10_2782 | 1905 Buick Model 10 Sedan - Museum Grade | Vintage Cars | 87.82 | 175.72 |
| S24_4370 | 1905 Ford Model T Roadster | Vintage Cars | 29.33 | 57.66 |
| S18_3209 | 1905 Mercedes-Benz SSK Fastback - Limited Run | Vintage Cars | 57.70 | 90.85 |
| S50_2501 | 1905 Rolls-Royce Phantom Coupe - Premium Finish | Vintage Cars | 78.51 | 176.10 |
| S32_3659 | 1906 Chevrolet Superior | Vintage Cars | 24.83 | 41.76 |
| S50_3134 | 1906 Ford Model A - Limited Run | Vintage Cars | 35.45 | 74.03 |

*25 row(s) returned (showing first 10).*

### B02 - Classic Cars

**Question:** Show the 20 most expensive products (by MSRP) in the 'Classic Cars' line.  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT productCode, productName, MSRP
FROM products
WHERE productLine = 'Classic Cars'
ORDER BY MSRP DESC, productName
LIMIT 20;
```

| productCode | productName | MSRP |
|---|---|---|
| S32_2361 | 1971 Toyota 2000GT - Premium Finish | 213.86 |
| S50_3283 | 1979 Citroen DS Convertible - Collector Series | 201.41 |
| S18_4211 | 1997 Buick Riviera Fastback - Desert Camo | 196.98 |
| S72_1443 | 1978 Ferrari 250 GTO - Museum Grade | 190.55 |
| S12_1557 | 1979 Lotus Elan Convertible - Silver Edition | 186.12 |
| S24_3059 | 1971 Ford Thunderbird Coupe | 181.60 |
| S32_3925 | 1973 Datsun 240Z Coupe | 180.12 |
| S18_4655 | 1948 Triumph TR6 Tourer - Museum Grade | 178.80 |
| S24_3262 | 1975 Porsche 911 Convertible - Desert Camo | 175.74 |
| S32_2137 | 1958 Ford Falcon Sedan - Museum Grade | 175.44 |

*20 row(s) returned (showing first 10).*

### B03 - Motorcycles, planes and ships

**Question:** List products in the Motorcycles, Planes or Ships lines, sorted by line then name (first 25).  
**Skills:** WHERE, IN, ORDER BY, LIMIT

```sql
SELECT productName, productLine, productScale, MSRP
FROM products
WHERE productLine IN ('Motorcycles', 'Planes', 'Ships')
ORDER BY productLine, productName
LIMIT 25;
```

| productName | productLine | productScale | MSRP |
|---|---|---|---|
| 1937 Aprilia Super Cub - Desert Camo | Motorcycles | 1:18 | 48.71 |
| 1937 Vespa Softail | Motorcycles | 1:24 | 131.36 |
| 1938 Lambretta Café Racer - Desert Camo | Motorcycles | 1:18 | 113.32 |
| 1938 Yamaha Ultimate Chopper | Motorcycles | 1:24 | 155.43 |
| 1939 Indian Gold Wing | Motorcycles | 1:18 | 105.26 |
| 1939 Lambretta Panigale - Premium Finish | Motorcycles | 1:12 | 135.88 |
| 1940 Vespa Commando | Motorcycles | 1:700 | 70.60 |
| 1941 Yamaha Monster - Premium Finish | Motorcycles | 1:12 | 145.01 |
| 1942 Triumph Super Cub - Museum Grade | Motorcycles | 1:24 | 120.35 |
| 1943 Aprilia Thunderbird | Motorcycles | 1:18 | 125.69 |

*25 row(s) returned (showing first 10).*

### B04 - Products that are not cars

**Question:** How many products are not in the Classic Cars or Vintage Cars lines?  
**Skills:** NOT IN, COUNT

```sql
SELECT COUNT(*) AS non_car_products
FROM products
WHERE productLine NOT IN ('Classic Cars', 'Vintage Cars');
```

| non_car_products |
|---|
| 300 |

*1 row(s) returned.*

### B05 - Expensive to buy

**Question:** Which products cost more than 80 to buy? Show the top 20 by buy price.  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT productCode, productName, productLine, buyPrice
FROM products
WHERE buyPrice > 80
ORDER BY buyPrice DESC, productName
LIMIT 20;
```

| productCode | productName | productLine | buyPrice |
|---|---|---|---|
| S24_3059 | 1971 Ford Thunderbird Coupe | Classic Cars | 99.62 |
| S700_2495 | 1967 Mini Cooper - Premium Finish | Classic Cars | 98.75 |
| S32_2361 | 1971 Toyota 2000GT - Premium Finish | Classic Cars | 98.24 |
| S72_1443 | 1978 Ferrari 250 GTO - Museum Grade | Classic Cars | 97.80 |
| S32_2137 | 1958 Ford Falcon Sedan - Museum Grade | Classic Cars | 96.47 |
| S18_4655 | 1948 Triumph TR6 Tourer - Museum Grade | Classic Cars | 96.43 |
| S18_4211 | 1997 Buick Riviera Fastback - Desert Camo | Classic Cars | 95.64 |
| S50_4145 | 1952 BMW Café Racer - Museum Grade | Motorcycles | 95.54 |
| S24_3885 | 1997 Cadillac Eldorado Sedan - Museum Grade | Classic Cars | 95.52 |
| S12_2035 | 1945 Kenworth Logging Truck | Trucks and Buses | 95.50 |

*20 row(s) returned (showing first 10).*

### B06 - Retail price band

**Question:** How many products have an MSRP between 100 and 150?  
**Skills:** WHERE, BETWEEN, COUNT

```sql
SELECT COUNT(*) AS products_in_price_band
FROM products
WHERE MSRP BETWEEN 100 AND 150;
```

| products_in_price_band |
|---|
| 188 |

*1 row(s) returned.*

### B07 - Top 10 most expensive products

**Question:** What are the 10 highest-priced products by MSRP?  
**Skills:** ORDER BY, LIMIT

```sql
SELECT productCode, productName, productLine, MSRP
FROM products
ORDER BY MSRP DESC, productCode
LIMIT 10;
```

| productCode | productName | productLine | MSRP |
|---|---|---|---|
| S12_2035 | 1945 Kenworth Logging Truck | Trucks and Buses | 213.99 |
| S32_2361 | 1971 Toyota 2000GT - Premium Finish | Classic Cars | 213.86 |
| S50_3283 | 1979 Citroen DS Convertible - Collector Series | Classic Cars | 201.41 |
| S18_4211 | 1997 Buick Riviera Fastback - Desert Camo | Classic Cars | 196.98 |
| S18_4487 | 1949 Route 66 Diner Truck - Racing Livery | Trucks and Buses | 193.86 |
| S72_1443 | 1978 Ferrari 250 GTO - Museum Grade | Classic Cars | 190.55 |
| S32_2770 | 1934 Greyhound Bus | Trucks and Buses | 189.97 |
| S18_3746 | 1915 Delahaye 135 - Collector Series | Vintage Cars | 189.30 |
| S12_2929 | 1968 Lambretta Sportster | Motorcycles | 186.50 |
| S12_1557 | 1979 Lotus Elan Convertible - Silver Edition | Classic Cars | 186.12 |

*10 row(s) returned.*

### B08 - 5 cheapest products

**Question:** What are the 5 cheapest products to buy?  
**Skills:** ORDER BY, LIMIT

```sql
SELECT productCode, productName, productLine, buyPrice
FROM products
ORDER BY buyPrice ASC, productCode
LIMIT 5;
```

| productCode | productName | productLine | buyPrice |
|---|---|---|---|
| S24_2857 | 1904 Bentley 4.5 Litre Coupe - Premium Finish | Vintage Cars | 16.00 |
| S50_1299 | 1941 Daimler DE36 Convertible | Vintage Cars | 16.16 |
| S18_3362 | 1929 Hispano-Suiza H6 Coupe - Desert Camo | Vintage Cars | 16.32 |
| S12_4104 | 1922 Bentley 4.5 Litre Sedan - Limited Run | Vintage Cars | 17.61 |
| S18_2707 | 1943 Cadillac V16 - Limited Run | Vintage Cars | 17.98 |

*5 row(s) returned.*

### B09 - Products per line

**Question:** How many products are in each product line?  
**Skills:** GROUP BY, COUNT, ORDER BY

```sql
SELECT productLine, COUNT(*) AS total_products
FROM products
GROUP BY productLine
ORDER BY total_products DESC, productLine;
```

| productLine | total_products |
|---|---|
| Classic Cars | 110 |
| Vintage Cars | 90 |
| Trucks and Buses | 80 |
| Planes | 70 |
| Motorcycles | 60 |
| Ships | 50 |
| Trains | 40 |

*7 row(s) returned.*

### B10 - Average prices per line

**Question:** What are the average buy price and average MSRP of each product line?  
**Skills:** GROUP BY, AVG, ROUND

```sql
SELECT productLine,
       ROUND(AVG(buyPrice), 2) AS avg_buy_price,
       ROUND(AVG(MSRP), 2)     AS avg_msrp
FROM products
GROUP BY productLine
ORDER BY avg_msrp DESC;
```

| productLine | avg_buy_price | avg_msrp |
|---|---|---|
| Trucks and Buses | 60.48 | 115.36 |
| Motorcycles | 61.11 | 113.93 |
| Classic Cars | 57.82 | 108.50 |
| Planes | 54.44 | 102.68 |
| Ships | 52.52 | 98.08 |
| Vintage Cars | 49.87 | 92.84 |
| Trains | 41.17 | 75.67 |

*7 row(s) returned.*

### B11 - Premium lines

**Question:** Which product lines have an average MSRP above 100?  
**Skills:** GROUP BY, HAVING, AVG

```sql
SELECT productLine, ROUND(AVG(MSRP), 2) AS avg_msrp
FROM products
GROUP BY productLine
HAVING AVG(MSRP) > 100
ORDER BY avg_msrp DESC;
```

| productLine | avg_msrp |
|---|---|
| Trucks and Buses | 115.36 |
| Motorcycles | 113.93 |
| Classic Cars | 108.50 |
| Planes | 102.68 |

*4 row(s) returned.*

### B12 - Price range per line

**Question:** What are the lowest MSRP, highest MSRP and price spread of every product line?  
**Skills:** GROUP BY, MIN, MAX

```sql
SELECT productLine,
       MIN(MSRP)            AS lowest_msrp,
       MAX(MSRP)            AS highest_msrp,
       MAX(MSRP) - MIN(MSRP) AS price_spread
FROM products
GROUP BY productLine
ORDER BY price_spread DESC;
```

| productLine | lowest_msrp | highest_msrp | price_spread |
|---|---|---|---|
| Classic Cars | 34.41 | 213.86 | 179.45 |
| Trucks and Buses | 50.06 | 213.99 | 163.93 |
| Vintage Cars | 26.81 | 189.30 | 162.49 |
| Motorcycles | 48.71 | 186.50 | 137.79 |
| Planes | 45.80 | 176.41 | 130.61 |
| Ships | 36.96 | 159.67 | 122.71 |
| Trains | 34.65 | 137.11 | 102.46 |

*7 row(s) returned.*

### B13 - Low stock

**Question:** Which products have fewer than 500 units in stock? Show the 25 lowest.  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT productCode, productName, productLine, quantityInStock
FROM products
WHERE quantityInStock < 500
ORDER BY quantityInStock ASC, productName
LIMIT 25;
```

| productCode | productName | productLine | quantityInStock |
|---|---|---|---|
| S12_2929 | 1968 Lambretta Sportster | Motorcycles | 1 |
| S24_1808 | Boeing 787 Dreamliner - Racing Livery | Planes | 8 |
| S24_3702 | Nautilus Submarine | Ships | 11 |
| S24_1284 | 1992 Aston Martin DB5 Roadster | Classic Cars | 20 |
| S24_2138 | Orient Express Coach - Premium Finish | Trains | 22 |
| S32_4051 | Bell UH-1 Huey | Planes | 25 |
| S18_1026 | 1946 Bugatti Royale Convertible - Silver Edition | Vintage Cars | 27 |
| S18_3529 | 1949 Studebaker Avanti Tourer - Collector Series | Classic Cars | 27 |
| S18_1126 | 1983 Tow Truck - Racing Livery | Trucks and Buses | 27 |
| S18_1446 | 1952 Dodge Charger - Museum Grade | Classic Cars | 30 |

*25 row(s) returned (showing first 10).*

### B14 - Critical stock by line

**Question:** How many products per line have fewer than 100 units in stock?  
**Skills:** WHERE, GROUP BY, COUNT

```sql
SELECT productLine, COUNT(*) AS critical_products
FROM products
WHERE quantityInStock < 100
GROUP BY productLine
ORDER BY critical_products DESC, productLine;
```

| productLine | critical_products |
|---|---|
| Classic Cars | 7 |
| Vintage Cars | 5 |
| Planes | 4 |
| Ships | 3 |
| Motorcycles | 2 |
| Trucks and Buses | 2 |
| Trains | 1 |

*7 row(s) returned.*

### B15 - Total stock per line

**Question:** How many units are in stock for each product line?  
**Skills:** GROUP BY, SUM

```sql
SELECT productLine, SUM(quantityInStock) AS units_in_stock
FROM products
GROUP BY productLine
ORDER BY units_in_stock DESC;
```

| productLine | units_in_stock |
|---|---|
| Classic Cars | 379394 |
| Trucks and Buses | 363925 |
| Vintage Cars | 344791 |
| Planes | 308692 |
| Motorcycles | 255275 |
| Ships | 214206 |
| Trains | 203428 |

*7 row(s) returned.*

### B16 - Lines with big inventory

**Question:** Which product lines hold more than 300,000 units in stock?  
**Skills:** GROUP BY, HAVING, SUM

```sql
SELECT productLine, SUM(quantityInStock) AS units_in_stock
FROM products
GROUP BY productLine
HAVING SUM(quantityInStock) > 300000
ORDER BY units_in_stock DESC;
```

| productLine | units_in_stock |
|---|---|
| Classic Cars | 379394 |
| Trucks and Buses | 363925 |
| Vintage Cars | 344791 |
| Planes | 308692 |

*4 row(s) returned.*

### B17 - Healthy stock band

**Question:** List products with between 5,000 and 9,000 units in stock, largest stock first (first 20).  
**Skills:** WHERE, BETWEEN, ORDER BY, LIMIT

```sql
SELECT productName, productLine, quantityInStock
FROM products
WHERE quantityInStock BETWEEN 5000 AND 9000
ORDER BY quantityInStock DESC, productName
LIMIT 20;
```

| productName | productLine | quantityInStock |
|---|---|---|
| Golden Hind | Ships | 8962 |
| 1943 London Double-Decker Bus - Museum Grade | Trucks and Buses | 8942 |
| 1968 Kenworth Logging Truck - Desert Camo | Trucks and Buses | 8925 |
| Learjet 23 - Silver Edition | Planes | 8892 |
| Supermarine Seafire | Planes | 8873 |
| Dhow of Zanzibar - Desert Camo | Ships | 8841 |
| 1910 Chevrolet Superior - Silver Edition | Vintage Cars | 8825 |
| Spitfire Mk IX - Desert Camo | Planes | 8801 |
| 1907 Mercedes-Benz SSK Convertible | Vintage Cars | 8738 |
| 1986 Ford Falcon - Museum Grade | Classic Cars | 8729 |

*20 row(s) returned (showing first 10).*

### B18 - Overstocked products

**Question:** Which 15 products have more than 9,000 units in stock?  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT productName, productLine, quantityInStock
FROM products
WHERE quantityInStock > 9000
ORDER BY quantityInStock DESC, productName
LIMIT 15;
```

| productName | productLine | quantityInStock |
|---|---|---|
| 1961 Studebaker Avanti - Collector Series | Classic Cars | 9437 |
| 1924 Hispano-Suiza H6 Coupe | Vintage Cars | 9419 |
| Lancaster Bomber - Premium Finish | Planes | 9415 |
| 1935 Flatbed Lorry - Silver Edition | Trucks and Buses | 9396 |
| TGV Duplex | Trains | 9386 |
| 1952 BMW Thunderbird - Racing Livery | Motorcycles | 9314 |
| Boeing 747 | Planes | 9313 |
| Royal Scot - Racing Livery | Trains | 9302 |
| Supermarine Seafire - Limited Run | Planes | 9210 |
| Orient Express Coach - Silver Edition | Trains | 9203 |

*15 row(s) returned (showing first 10).*

### B19 - Name contains 'Ford'

**Question:** Find all products with 'Ford' in the name.  
**Skills:** LIKE '%Ford%', ORDER BY

```sql
SELECT productCode, productName, productLine, MSRP
FROM products
WHERE productName LIKE '%Ford%'
ORDER BY productName
LIMIT 25;
```

| productCode | productName | productLine | MSRP |
|---|---|---|---|
| S24_4370 | 1905 Ford Model T Roadster | Vintage Cars | 57.66 |
| S50_3134 | 1906 Ford Model A - Limited Run | Vintage Cars | 74.03 |
| S18_4463 | 1915 Ford Model A - Desert Camo | Vintage Cars | 46.31 |
| S24_4096 | 1921 Ford Model T Convertible - Racing Livery | Vintage Cars | 145.74 |
| S18_3244 | 1923 Ford Model A Coupe - Museum Grade | Vintage Cars | 110.90 |
| S50_2266 | 1948 Ford Mustang - Limited Run | Classic Cars | 132.29 |
| S18_2772 | 1957 Ford Fairlane Sedan - Racing Livery | Classic Cars | 118.23 |
| S32_2137 | 1958 Ford Falcon Sedan - Museum Grade | Classic Cars | 175.44 |
| S18_2473 | 1959 Ford Thunderbird Convertible | Classic Cars | 148.48 |
| S12_1946 | 1960 Ford Fairlane - Racing Livery | Classic Cars | 83.86 |

*17 row(s) returned (showing first 10).*

### B20 - Name starts with '1969'

**Question:** Find all products whose name starts with '1969'.  
**Skills:** LIKE '1969%', ORDER BY

```sql
SELECT productCode, productName, productLine, MSRP
FROM products
WHERE productName LIKE '1969%'
ORDER BY productName;
```

| productCode | productName | productLine | MSRP |
|---|---|---|---|
| S24_3333 | 1969 Chevrolet Corvette Sedan - Limited Run | Classic Cars | 58.53 |
| S72_3578 | 1969 Peterbilt Tanker | Trucks and Buses | 153.43 |
| S72_2143 | 1969 Vespa Gold Wing | Motorcycles | 128.02 |

*3 row(s) returned.*

### B21 - Description search

**Question:** Find classic or vintage cars whose description mentions 'opening doors' (first 15).  
**Skills:** LIKE on a text column, AND, IN

```sql
SELECT productName, productLine, productScale
FROM products
WHERE productDescription LIKE '%opening doors%'
  AND productLine IN ('Classic Cars', 'Vintage Cars')
ORDER BY productName
LIMIT 15;
```

| productName | productLine | productScale |
|---|---|---|
| 1906 Ford Model A - Limited Run | Vintage Cars | 1:50 |
| 1908 Buick Model 10 Convertible | Vintage Cars | 1:24 |
| 1912 Cord 810 | Vintage Cars | 1:24 |
| 1915 Hispano-Suiza H6 Sedan | Vintage Cars | 1:10 |
| 1916 Peugeot Type 3 - Limited Run | Vintage Cars | 1:10 |
| 1921 Cadillac V16 Convertible - Museum Grade | Vintage Cars | 1:18 |
| 1922 Bentley 4.5 Litre Sedan - Limited Run | Vintage Cars | 1:12 |
| 1922 Peugeot Type 3 Fastback - Racing Livery | Vintage Cars | 1:24 |
| 1923 Ford Model A Coupe - Museum Grade | Vintage Cars | 1:18 |
| 1924 Hispano-Suiza H6 Coupe | Vintage Cars | 1:32 |

*15 row(s) returned (showing first 10).*

### B22 - Vendor search

**Question:** How many products come from vendors whose name contains 'Diecast'? Break it down by vendor.  
**Skills:** LIKE, GROUP BY, COUNT

```sql
SELECT productVendor, COUNT(*) AS total_products
FROM products
WHERE productVendor LIKE '%Diecast%'
GROUP BY productVendor
ORDER BY total_products DESC, productVendor;
```

| productVendor | total_products |
|---|---|
| Silverline Diecast | 36 |
| Red Start Diecast | 30 |
| Welly Diecast Productions | 26 |
| Second Gear Diecast | 25 |
| Min Lin Diecast | 19 |
| Carousel DieCast Legends | 18 |

*6 row(s) returned.*

### B23 - Biggest vendors

**Question:** Which vendors supply more than 25 products?  
**Skills:** GROUP BY, HAVING

```sql
SELECT productVendor, COUNT(*) AS total_products
FROM products
GROUP BY productVendor
HAVING COUNT(*) > 25
ORDER BY total_products DESC, productVendor;
```

| productVendor | total_products |
|---|---|
| Highway 66 Mini Classics | 36 |
| Silverline Diecast | 36 |
| Gearbox Collectibles | 34 |
| Red Start Diecast | 30 |
| Iron Horse Miniatures | 29 |
| Heritage Mint | 28 |
| Autoart Studio Design | 27 |
| Blue Harbour Models | 26 |
| Motor City Art Classics | 26 |
| Studio M Art Models | 26 |

*11 row(s) returned (showing first 10).*

### B24 - Scale filter

**Question:** Show 1:18 scale models in the Classic Cars and Vintage Cars lines, cheapest first (first 20).  
**Skills:** WHERE, AND, IN, ORDER BY, LIMIT

```sql
SELECT productName, productLine, productScale, MSRP
FROM products
WHERE productScale = '1:18'
  AND productLine IN ('Classic Cars', 'Vintage Cars')
ORDER BY MSRP ASC, productName
LIMIT 20;
```

| productName | productLine | productScale | MSRP |
|---|---|---|---|
| 1943 Cadillac V16 - Limited Run | Vintage Cars | 1:18 | 31.19 |
| 1929 Hispano-Suiza H6 Coupe - Desert Camo | Vintage Cars | 1:18 | 31.57 |
| 1990 Bentley Continental - Silver Edition | Classic Cars | 1:18 | 35.51 |
| 1945 Packard Twin Six Sedan | Vintage Cars | 1:18 | 40.74 |
| 1914 Cadillac V16 Tourer - Limited Run | Vintage Cars | 1:18 | 40.96 |
| 1926 Bentley 4.5 Litre - Premium Finish | Vintage Cars | 1:18 | 42.58 |
| 1954 Fiat 500 Sedan | Classic Cars | 1:18 | 43.31 |
| 1916 Cord 810 - Anniversary Edition | Vintage Cars | 1:18 | 45.07 |
| 1915 Ford Model A - Desert Camo | Vintage Cars | 1:18 | 46.31 |
| 1990 Ford Thunderbird - Limited Run | Classic Cars | 1:18 | 47.87 |

*20 row(s) returned (showing first 10).*

### B25 - Multi-column sort

**Question:** Sort products by product line (A-Z), then MSRP (high to low), then name (first 30).  
**Skills:** ORDER BY (three keys), LIMIT

```sql
SELECT productLine, productName, MSRP
FROM products
ORDER BY productLine ASC, MSRP DESC, productName ASC
LIMIT 30;
```

| productLine | productName | MSRP |
|---|---|---|
| Classic Cars | 1971 Toyota 2000GT - Premium Finish | 213.86 |
| Classic Cars | 1979 Citroen DS Convertible - Collector Series | 201.41 |
| Classic Cars | 1997 Buick Riviera Fastback - Desert Camo | 196.98 |
| Classic Cars | 1978 Ferrari 250 GTO - Museum Grade | 190.55 |
| Classic Cars | 1979 Lotus Elan Convertible - Silver Edition | 186.12 |
| Classic Cars | 1971 Ford Thunderbird Coupe | 181.60 |
| Classic Cars | 1973 Datsun 240Z Coupe | 180.12 |
| Classic Cars | 1948 Triumph TR6 Tourer - Museum Grade | 178.80 |
| Classic Cars | 1975 Porsche 911 Convertible - Desert Camo | 175.74 |
| Classic Cars | 1958 Ford Falcon Sedan - Museum Grade | 175.44 |

*30 row(s) returned (showing first 10).*

### B26 - Best margins

**Question:** Which 10 products earn the biggest absolute margin (MSRP - buy price)? Show the mark-up percentage too.  
**Skills:** calculated columns, ROUND, ORDER BY, LIMIT

```sql
SELECT productName, productLine, buyPrice, MSRP,
       ROUND(MSRP - buyPrice, 2)                     AS margin,
       ROUND((MSRP - buyPrice) * 100.0 / buyPrice, 1) AS markup_pct
FROM products
ORDER BY margin DESC, productName
LIMIT 10;
```

| productName | productLine | buyPrice | MSRP | margin | markup_pct |
|---|---|---|---|---|---|
| 1945 Kenworth Logging Truck | Trucks and Buses | 95.50 | 213.99 | 118.49 | 124.10 |
| 1971 Toyota 2000GT - Premium Finish | Classic Cars | 98.24 | 213.86 | 115.62 | 117.70 |
| 1979 Citroen DS Convertible - Collector Series | Classic Cars | 92.33 | 201.41 | 109.08 | 118.10 |
| 1915 Delahaye 135 - Collector Series | Vintage Cars | 84.41 | 189.30 | 104.89 | 124.30 |
| 1945 Bentley 4.5 Litre | Vintage Cars | 81.37 | 185.20 | 103.83 | 127.60 |
| 1971 Greyhound Bus - Racing Livery | Trucks and Buses | 80.64 | 182.46 | 101.82 | 126.30 |
| 1997 Buick Riviera Fastback - Desert Camo | Classic Cars | 95.64 | 196.98 | 101.34 | 106.00 |
| 1949 Route 66 Diner Truck - Racing Livery | Trucks and Buses | 93.15 | 193.86 | 100.71 | 108.10 |
| 1934 Greyhound Bus | Trucks and Buses | 90.68 | 189.97 | 99.29 | 109.50 |
| Avro Vulcan | Planes | 77.47 | 176.41 | 98.94 | 127.70 |

*10 row(s) returned.*

### B27 - Above-average price

**Question:** How many products have an MSRP above the catalogue average, and what is that average?  
**Skills:** subquery in WHERE and in SELECT

```sql
SELECT COUNT(*) AS products_above_average,
       (SELECT ROUND(AVG(MSRP), 2) FROM products) AS catalogue_avg_msrp
FROM products
WHERE MSRP > (SELECT AVG(MSRP) FROM products);
```

| products_above_average | catalogue_avg_msrp |
|---|---|
| 247 | 102.95 |

*1 row(s) returned.*

### B28 - Most expensive product in each line

**Question:** What is the highest-priced product in each product line?  
**Skills:** correlated subquery, MAX

```sql
SELECT productLine, productName, MSRP
FROM products p1
WHERE MSRP = (SELECT MAX(MSRP)
              FROM products p2
              WHERE p2.productLine = p1.productLine)
ORDER BY productLine;
```

| productLine | productName | MSRP |
|---|---|---|
| Classic Cars | 1971 Toyota 2000GT - Premium Finish | 213.86 |
| Motorcycles | 1968 Lambretta Sportster | 186.50 |
| Planes | Avro Vulcan | 176.41 |
| Ships | Mayflower - Anniversary Edition | 159.67 |
| Trains | Flying Scotsman | 137.11 |
| Trucks and Buses | 1945 Kenworth Logging Truck | 213.99 |
| Vintage Cars | 1915 Delahaye 135 - Collector Series | 189.30 |

*7 row(s) returned.*

### B29 - Products never ordered

**Question:** Which products have never been ordered? (first 20)  
**Skills:** NOT IN subquery, ORDER BY, LIMIT

```sql
SELECT productCode, productName, productLine, quantityInStock
FROM products
WHERE productCode NOT IN (SELECT productCode FROM orderdetails)
ORDER BY productLine, productName
LIMIT 20;
```

| productCode | productName | productLine | quantityInStock |
|---|---|---|---|
| S24_4731 | 1952 Oldsmobile 442 Tourer - Premium Finish | Classic Cars | 3578 |
| S18_1926 | 1964 Chevrolet Camaro Fastback - Collector Series | Classic Cars | 3906 |
| S700_1673 | 1964 Porsche 911 - Premium Finish | Classic Cars | 216 |
| S18_4848 | 1997 Pontiac GTO Sedan - Anniversary Edition | Classic Cars | 5799 |
| S18_3272 | F-16 Fighting Falcon - Desert Camo | Planes | 2085 |
| S24_2290 | Sopwith Camel - Premium Finish | Planes | 1970 |
| S18_3444 | Spitfire Mk IX - Museum Grade | Planes | 441 |
| S700_1196 | Bismarck - Racing Livery | Ships | 417 |
| S24_1928 | RMS Queen Mary | Ships | 171 |
| S18_1219 | Schooner Bluenose - Premium Finish | Ships | 214 |

*20 row(s) returned (showing first 10).*

### B30 - Best sellers

**Question:** What are the 10 best-selling products by total units ordered?  
**Skills:** GROUP BY, SUM, subquery in SELECT, ORDER BY, LIMIT

```sql
SELECT od.productCode,
       (SELECT p.productName FROM products p WHERE p.productCode = od.productCode) AS productName,
       SUM(od.quantityOrdered) AS units_sold
FROM orderdetails od
GROUP BY od.productCode
ORDER BY units_sold DESC, od.productCode
LIMIT 10;
```

| productCode | productName | units_sold |
|---|---|---|
| S24_1011 | 1951 Flatbed Lorry - Museum Grade | 54096 |
| S24_2756 | 1938 Bugatti Type 57 Tourer - Desert Camo | 48705 |
| S24_4467 | 1991 Volkswagen Type 2 Bus - Museum Grade | 44011 |
| S24_1496 | 1960 Aston Martin DB5 Fastback - Desert Camo | 43889 |
| S50_3134 | 1906 Ford Model A - Limited Run | 42104 |
| S72_4002 | Sea Cloud - Premium Finish | 40731 |
| S12_2987 | 1986 Nissan Skyline Tourer | 40633 |
| S24_4515 | 1983 Ford Falcon | 37031 |
| S12_2376 | 1928 Stutz Bearcat - Limited Run | 34870 |
| S24_4121 | 1907 Mercedes-Benz SSK Convertible | 34328 |

*10 row(s) returned.*

### B31 - Pagination - page 5

**Question:** Products are listed 20 per page in alphabetical order. Show page 5.  
**Skills:** ORDER BY, LIMIT, OFFSET

```sql
SELECT productCode, productName, productLine, MSRP
FROM products
ORDER BY productName
LIMIT 20 OFFSET 80;
```

| productCode | productName | productLine | MSRP |
|---|---|---|---|
| S24_2743 | 1935 Ice Cream Truck - Anniversary Edition | Trucks and Buses | 104.35 |
| S72_4051 | 1935 Trolley Bus | Trucks and Buses | 145.39 |
| S18_2841 | 1935 Yellow School Bus - Silver Edition | Trucks and Buses | 76.58 |
| S18_4439 | 1937 Aprilia Super Cub - Desert Camo | Motorcycles | 48.71 |
| S18_2119 | 1937 London Double-Decker Bus - Desert Camo | Trucks and Buses | 93.12 |
| S24_3589 | 1937 Vespa Softail | Motorcycles | 131.36 |
| S18_3888 | 1938 Bugatti Type 57 Sedan | Vintage Cars | 63.96 |
| S24_2756 | 1938 Bugatti Type 57 Tourer - Desert Camo | Vintage Cars | 125.18 |
| S18_2512 | 1938 Food Truck - Premium Finish | Trucks and Buses | 95.76 |
| S18_1915 | 1938 Lambretta Café Racer - Desert Camo | Motorcycles | 113.32 |

*20 row(s) returned (showing first 10).*

### B32 - Product with the most stock

**Question:** Which product has the highest quantity in stock?  
**Skills:** subquery with MAX

```sql
SELECT productCode, productName, productLine, quantityInStock
FROM products
WHERE quantityInStock = (SELECT MAX(quantityInStock) FROM products);
```

| productCode | productName | productLine | quantityInStock |
|---|---|---|---|
| S10_3151 | 1961 Studebaker Avanti - Collector Series | Classic Cars | 9437 |

*1 row(s) returned.*

### B33 - Above the average of its own line

**Question:** Which products are priced above the average MSRP of their own product line? (first 15 by MSRP)  
**Skills:** correlated subquery, AVG

```sql
SELECT productName, productLine, MSRP
FROM products p1
WHERE MSRP > (SELECT AVG(MSRP)
              FROM products p2
              WHERE p2.productLine = p1.productLine)
ORDER BY MSRP DESC, productName
LIMIT 15;
```

| productName | productLine | MSRP |
|---|---|---|
| 1945 Kenworth Logging Truck | Trucks and Buses | 213.99 |
| 1971 Toyota 2000GT - Premium Finish | Classic Cars | 213.86 |
| 1979 Citroen DS Convertible - Collector Series | Classic Cars | 201.41 |
| 1997 Buick Riviera Fastback - Desert Camo | Classic Cars | 196.98 |
| 1949 Route 66 Diner Truck - Racing Livery | Trucks and Buses | 193.86 |
| 1978 Ferrari 250 GTO - Museum Grade | Classic Cars | 190.55 |
| 1934 Greyhound Bus | Trucks and Buses | 189.97 |
| 1915 Delahaye 135 - Collector Series | Vintage Cars | 189.30 |
| 1968 Lambretta Sportster | Motorcycles | 186.50 |
| 1979 Lotus Elan Convertible - Silver Edition | Classic Cars | 186.12 |

*15 row(s) returned (showing first 10).*


---

## Section C - Payment Analysis

### C01 - Latest payments

**Question:** Show the 20 most recent payments.  
**Skills:** ORDER BY, LIMIT

```sql
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
ORDER BY paymentDate DESC, amount DESC
LIMIT 20;
```

| customerNumber | checkNumber | paymentDate | amount |
|---|---|---|---|
| 1445 | EV400206 | 2026-09-24 | 31,328.21 |
| 1671 | UR756679 | 2026-09-24 | 28,545.15 |
| 2510 | GD125155 | 2026-09-24 | 27,084.48 |
| 1215 | QJ372884 | 2026-09-24 | 26,810.43 |
| 196 | HT210185 | 2026-09-24 | 24,725.87 |
| 2132 | NB242578 | 2026-09-24 | 23,129.94 |
| 168 | JF477154 | 2026-09-24 | 19,008.14 |
| 1485 | PC279280 | 2026-09-24 | 18,688.34 |
| 2266 | HK969796 | 2026-09-24 | 17,117.50 |
| 843 | LF187345 | 2026-09-24 | 16,588.54 |

*20 row(s) returned (showing first 10).*

### C02 - Payments in 2025

**Question:** Which were the 20 largest payments received during 2025?  
**Skills:** WHERE, BETWEEN (dates), ORDER BY, LIMIT

```sql
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE paymentDate BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY amount DESC, paymentDate
LIMIT 20;
```

| customerNumber | checkNumber | paymentDate | amount |
|---|---|---|---|
| 2419 | YT276910 | 2025-07-06 | 52,861.81 |
| 1641 | XE223030 | 2025-07-02 | 52,441.59 |
| 2459 | SB925632 | 2025-07-01 | 52,005.71 |
| 2081 | EV869505 | 2025-06-08 | 49,222.48 |
| 973 | HU702667 | 2025-07-17 | 48,270.27 |
| 791 | MZ475425 | 2025-03-13 | 47,309.23 |
| 2312 | DL765585 | 2025-01-28 | 46,910.06 |
| 1993 | FU495245 | 2025-06-23 | 46,683.96 |
| 930 | CZ556020 | 2025-08-16 | 46,284.49 |
| 693 | FG910340 | 2025-03-08 | 46,020.61 |

*20 row(s) returned (showing first 10).*

### C03 - Q4 2025 cash-in

**Question:** How many payments were received in Q4 2025 and what was their total?  
**Skills:** WHERE, BETWEEN, COUNT, SUM

```sql
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
WHERE paymentDate BETWEEN '2025-10-01' AND '2025-12-31';
```

| payments_made | total_received |
|---|---|
| 1356 | 22,136,520.75 |

*1 row(s) returned.*

### C04 - A specific month

**Question:** How many payments arrived in March 2026 and what was their total?  
**Skills:** WHERE with YEAR() and MONTH(), COUNT, SUM

```sql
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
WHERE YEAR(paymentDate) = 2026
  AND MONTH(paymentDate) = 3;
```

| payments_made | total_received |
|---|---|
| 281 | 4,552,587.90 |

*1 row(s) returned.*

### C05 - Payments per year

**Question:** How many payments were received each year and how much money did they bring in?  
**Skills:** GROUP BY YEAR(), COUNT, SUM

```sql
SELECT YEAR(paymentDate)     AS pay_year,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
GROUP BY YEAR(paymentDate)
ORDER BY pay_year;
```

| pay_year | payments_made | total_received |
|---|---|---|
| 2022 | 2593 | 42,969,173.43 |
| 2023 | 3229 | 53,031,174.33 |
| 2024 | 3822 | 62,288,474.08 |
| 2025 | 4222 | 69,194,458.82 |
| 2026 | 3067 | 49,820,931.98 |

*5 row(s) returned.*

### C06 - Payments per month in 2025

**Question:** Break 2025 down by month: payment count and total received.  
**Skills:** WHERE, GROUP BY MONTH(), COUNT, SUM

```sql
SELECT MONTH(paymentDate)    AS pay_month,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
WHERE YEAR(paymentDate) = 2025
GROUP BY MONTH(paymentDate)
ORDER BY pay_month;
```

| pay_month | payments_made | total_received |
|---|---|---|
| 1 | 417 | 6,730,493.47 |
| 2 | 284 | 4,746,222.92 |
| 3 | 269 | 4,462,833.90 |
| 4 | 266 | 4,357,076.32 |
| 5 | 281 | 4,654,348.66 |
| 6 | 308 | 4,990,834.35 |
| 7 | 360 | 5,928,005.41 |
| 8 | 346 | 5,649,130.66 |
| 9 | 335 | 5,538,992.38 |
| 10 | 407 | 6,973,282.63 |

*12 row(s) returned (showing first 10).*

### C07 - Busiest payment months

**Question:** Which 5 calendar months (year + month) saw the most payments?  
**Skills:** GROUP BY (two expressions), COUNT, ORDER BY, LIMIT

```sql
SELECT YEAR(paymentDate)  AS pay_year,
       MONTH(paymentDate) AS pay_month,
       COUNT(*)           AS payments_made
FROM payments
GROUP BY YEAR(paymentDate), MONTH(paymentDate)
ORDER BY payments_made DESC, pay_year DESC, pay_month DESC
LIMIT 5;
```

| pay_year | pay_month | payments_made |
|---|---|---|
| 2025 | 12 | 489 |
| 2024 | 12 | 478 |
| 2025 | 11 | 460 |
| 2026 | 1 | 457 |
| 2025 | 1 | 417 |

*5 row(s) returned.*

### C08 - First and last payment

**Question:** When was the first payment received and when was the most recent one?  
**Skills:** MIN, MAX on dates

```sql
SELECT MIN(paymentDate) AS first_payment,
       MAX(paymentDate) AS latest_payment
FROM payments;
```

| first_payment | latest_payment |
|---|---|
| 2022-01-15 | 2026-09-24 |

*1 row(s) returned.*

### C09 - Payments before 2024

**Question:** How many payments were received before 2024? (i.e. the year is NOT 2024, 2025 or 2026)  
**Skills:** WHERE, NOT IN, COUNT

```sql
SELECT COUNT(*) AS payments_before_2024
FROM payments
WHERE YEAR(paymentDate) NOT IN (2024, 2025, 2026);
```

| payments_before_2024 |
|---|
| 5822 |

*1 row(s) returned.*

### C10 - Best payment days

**Question:** On which 5 dates did we receive the most money in total?  
**Skills:** GROUP BY, SUM, ORDER BY, LIMIT

```sql
SELECT paymentDate,
       COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_received
FROM payments
GROUP BY paymentDate
ORDER BY total_received DESC
LIMIT 5;
```

| paymentDate | payments_made | total_received |
|---|---|---|
| 2024-12-18 | 29 | 538,682.35 |
| 2025-02-08 | 20 | 436,770.15 |
| 2025-10-25 | 24 | 431,473.24 |
| 2025-11-12 | 21 | 421,741.56 |
| 2025-01-02 | 24 | 408,435.65 |

*5 row(s) returned.*

### C11 - Most active payers

**Question:** Which 10 customers have made the most payments?  
**Skills:** GROUP BY, COUNT, ORDER BY, LIMIT

```sql
SELECT customerNumber, COUNT(*) AS payments_made
FROM payments
GROUP BY customerNumber
ORDER BY payments_made DESC, customerNumber
LIMIT 10;
```

| customerNumber | payments_made |
|---|---|
| 1789 | 59 |
| 2430 | 55 |
| 1717 | 48 |
| 1800 | 44 |
| 2263 | 42 |
| 1201 | 41 |
| 1380 | 41 |
| 2355 | 41 |
| 696 | 40 |
| 1592 | 40 |

*10 row(s) returned.*

### C12 - Frequent payers

**Question:** Which customers have made more than 20 payments? (top 15)  
**Skills:** GROUP BY, HAVING, COUNT, LIMIT

```sql
SELECT customerNumber, COUNT(*) AS payments_made
FROM payments
GROUP BY customerNumber
HAVING COUNT(*) > 20
ORDER BY payments_made DESC, customerNumber
LIMIT 15;
```

| customerNumber | payments_made |
|---|---|
| 1789 | 59 |
| 2430 | 55 |
| 1717 | 48 |
| 1800 | 44 |
| 2263 | 42 |
| 1201 | 41 |
| 1380 | 41 |
| 2355 | 41 |
| 696 | 40 |
| 1592 | 40 |

*15 row(s) returned (showing first 10).*

### C13 - One-time payers

**Question:** How many customers have made exactly one payment?  
**Skills:** derived table (subquery in FROM), HAVING, COUNT

```sql
SELECT COUNT(*) AS customers_with_one_payment
FROM (SELECT customerNumber
      FROM payments
      GROUP BY customerNumber
      HAVING COUNT(*) = 1) AS single_payment;
```

| customers_with_one_payment |
|---|
| 143 |

*1 row(s) returned.*

### C14 - Payers above the typical frequency

**Question:** Which customers have made more payments than the average number of payments per paying customer? (top 10)  
**Skills:** HAVING with a subquery

```sql
SELECT customerNumber, COUNT(*) AS payments_made
FROM payments
GROUP BY customerNumber
HAVING COUNT(*) > (SELECT COUNT(*) * 1.0 / COUNT(DISTINCT customerNumber) FROM payments)
ORDER BY payments_made DESC, customerNumber
LIMIT 10;
```

| customerNumber | payments_made |
|---|---|
| 1789 | 59 |
| 2430 | 55 |
| 1717 | 48 |
| 1800 | 44 |
| 2263 | 42 |
| 1201 | 41 |
| 1380 | 41 |
| 2355 | 41 |
| 696 | 40 |
| 1592 | 40 |

*10 row(s) returned.*

### C15 - Customers who paid in 2024 and 2025

**Question:** How many customers made at least one payment in 2024 AND at least one in 2025?  
**Skills:** IN with two subqueries, COUNT

```sql
SELECT COUNT(*) AS customers_paying_both_years
FROM customers
WHERE customerNumber IN (SELECT customerNumber FROM payments WHERE YEAR(paymentDate) = 2024)
  AND customerNumber IN (SELECT customerNumber FROM payments WHERE YEAR(paymentDate) = 2025);
```

| customers_paying_both_years |
|---|
| 1260 |

*1 row(s) returned.*

### C16 - Japanese customers' payments

**Question:** How much have customers from Japan paid in total?  
**Skills:** IN subquery, SUM, COUNT

```sql
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_paid
FROM payments
WHERE customerNumber IN (SELECT customerNumber FROM customers WHERE country = 'Japan');
```

| payments_made | total_paid |
|---|---|
| 1412 | 23,206,226.88 |

*1 row(s) returned.*

### C17 - Check number search

**Question:** How many payments have a check number starting with 'H'?  
**Skills:** LIKE 'H%', COUNT

```sql
SELECT COUNT(*) AS payments_with_H_check
FROM payments
WHERE checkNumber LIKE 'H%';
```

| payments_with_H_check |
|---|
| 708 |

*1 row(s) returned.*

### C18 - Top 10 customers by total paid

**Question:** Who are the 10 customers that have paid us the most in total?  
**Skills:** GROUP BY, SUM, COUNT, subquery in SELECT, ORDER BY, LIMIT

```sql
SELECT p.customerNumber,
       (SELECT c.customerName FROM customers c WHERE c.customerNumber = p.customerNumber) AS customerName,
       COUNT(*)              AS payments_made,
       ROUND(SUM(p.amount), 2) AS total_paid
FROM payments p
GROUP BY p.customerNumber
ORDER BY total_paid DESC
LIMIT 10;
```

| customerNumber | customerName | payments_made | total_paid |
|---|---|---|---|
| 1789 | Horizon Models GmbH | 59 | 884,999.70 |
| 1717 | Dragon Merchants Group | 48 | 881,244.29 |
| 1800 | Jade Collectibles Group | 44 | 837,621.91 |
| 2430 | Crimson Classics B.V. | 55 | 837,404.25 |
| 2263 | Enthusiast Models Pty | 42 | 722,417.25 |
| 1380 | Delta Distributors Group | 41 | 720,910.67 |
| 1201 | Diecast Collectables & Figli | 41 | 697,281.62 |
| 696 | Metro Emporium S.L. | 40 | 685,580.57 |
| 2355 | Enthusiast Souvenirs Pte Ltd | 41 | 669,439.41 |
| 1174 | Western Designs Pvt Ltd | 37 | 635,796.91 |

*10 row(s) returned.*

### C19 - Customers with low lifetime payments

**Question:** Which customers have paid less than 5,000 in total? (15 lowest)  
**Skills:** GROUP BY, HAVING, SUM

```sql
SELECT customerNumber, ROUND(SUM(amount), 2) AS total_paid
FROM payments
GROUP BY customerNumber
HAVING SUM(amount) < 5000
ORDER BY total_paid ASC
LIMIT 15;
```

| customerNumber | total_paid |
|---|---|
| 2198 | 1,175.04 |
| 2033 | 1,622.60 |
| 1879 | 1,765.92 |
| 962 | 1,980.90 |
| 1285 | 2,297.86 |
| 173 | 3,079.94 |
| 2244 | 3,371.56 |
| 752 | 4,680.50 |

*8 row(s) returned.*

### C20 - High average payers

**Question:** Which customers pay more than 25,000 on average per payment? (top 15)  
**Skills:** GROUP BY, HAVING AVG, ORDER BY, LIMIT

```sql
SELECT customerNumber,
       COUNT(*)                AS payments_made,
       ROUND(AVG(amount), 2)   AS avg_payment
FROM payments
GROUP BY customerNumber
HAVING AVG(amount) > 25000
ORDER BY avg_payment DESC
LIMIT 15;
```

| customerNumber | payments_made | avg_payment |
|---|---|---|
| 1139 | 1 | 41,014.05 |
| 1254 | 1 | 38,857.63 |
| 253 | 1 | 35,657.44 |
| 1072 | 3 | 35,029.60 |
| 1121 | 1 | 34,964.42 |
| 2484 | 1 | 33,889.37 |
| 335 | 2 | 33,081.05 |
| 1150 | 1 | 32,977.18 |
| 762 | 1 | 32,922.68 |
| 1525 | 1 | 32,904.96 |

*15 row(s) returned (showing first 10).*

### C21 - Total payments received

**Question:** What is the total amount of all payments and how many payments were made?  
**Skills:** SUM, COUNT

```sql
SELECT COUNT(*)              AS total_payments,
       ROUND(SUM(amount), 2) AS total_amount
FROM payments;
```

| total_payments | total_amount |
|---|---|
| 16933 | 277,304,212.64 |

*1 row(s) returned.*

### C22 - Average payment

**Question:** What is the average payment amount?  
**Skills:** AVG, ROUND

```sql
SELECT ROUND(AVG(amount), 2) AS average_payment
FROM payments;
```

| average_payment |
|---|
| 16,376.56 |

*1 row(s) returned.*

### C23 - Smallest and largest payment

**Question:** What are the minimum and maximum payment amounts?  
**Skills:** MIN, MAX

```sql
SELECT MIN(amount) AS min_payment,
       MAX(amount) AS max_payment
FROM payments;
```

| min_payment | max_payment |
|---|---|
| 241.20 | 60,168.04 |

*1 row(s) returned.*

### C24 - Payment summary in one row

**Question:** Give a one-row payment summary: count, total, average, minimum and maximum.  
**Skills:** COUNT, SUM, AVG, MIN, MAX

```sql
SELECT COUNT(*)              AS payments_made,
       ROUND(SUM(amount), 2) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount,
       MIN(amount)           AS min_amount,
       MAX(amount)           AS max_amount
FROM payments;
```

| payments_made | total_amount | avg_amount | min_amount | max_amount |
|---|---|---|---|---|
| 16933 | 277,304,212.64 | 16,376.56 | 241.20 | 60,168.04 |

*1 row(s) returned.*

### C25 - Payments over 50,000

**Question:** List payments above 50,000, largest first (top 20).  
**Skills:** WHERE, ORDER BY, LIMIT

```sql
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 50000
ORDER BY amount DESC
LIMIT 20;
```

| customerNumber | checkNumber | paymentDate | amount |
|---|---|---|---|
| 1048 | PT941646 | 2026-02-04 | 60,168.04 |
| 2293 | GY155581 | 2023-08-17 | 54,020.90 |
| 1098 | RK122976 | 2024-11-12 | 53,547.18 |
| 1811 | GN495431 | 2026-09-23 | 53,088.01 |
| 2419 | YT276910 | 2025-07-06 | 52,861.81 |
| 1423 | FL702446 | 2022-12-02 | 52,845.94 |
| 1641 | XE223030 | 2025-07-02 | 52,441.59 |
| 2459 | SB925632 | 2025-07-01 | 52,005.71 |
| 410 | PP748691 | 2022-12-19 | 50,918.06 |
| 929 | DD946493 | 2026-08-05 | 50,253.53 |

*12 row(s) returned (showing first 10).*

### C26 - Payment band

**Question:** How many payments were between 10,000 and 20,000 and how much did they total?  
**Skills:** BETWEEN, COUNT, SUM

```sql
SELECT COUNT(*)              AS payments_in_band,
       ROUND(SUM(amount), 2) AS band_total
FROM payments
WHERE amount BETWEEN 10000 AND 20000;
```

| payments_in_band | band_total |
|---|---|
| 7031 | 103,450,053.56 |

*1 row(s) returned.*

### C27 - Above-average payments

**Question:** How many payments are larger than the average payment?  
**Skills:** subquery in WHERE, COUNT

```sql
SELECT COUNT(*) AS above_average_payments
FROM payments
WHERE amount > (SELECT AVG(amount) FROM payments);
```

| above_average_payments |
|---|
| 7668 |

*1 row(s) returned.*

### C28 - The largest payment ever

**Question:** Who made the single largest payment, when, and how much?  
**Skills:** subquery with MAX, subquery in SELECT

```sql
SELECT p.customerNumber,
       (SELECT c.customerName FROM customers c WHERE c.customerNumber = p.customerNumber) AS customerName,
       p.paymentDate,
       p.amount
FROM payments p
WHERE p.amount = (SELECT MAX(amount) FROM payments);
```

| customerNumber | customerName | paymentDate | amount |
|---|---|---|---|
| 1048 | Classic Hobbies Group | 2026-02-04 | 60,168.04 |

*1 row(s) returned.*

### C29 - The smallest payment ever

**Question:** Who made the single smallest payment, when, and how much?  
**Skills:** subquery with MIN

```sql
SELECT p.customerNumber,
       (SELECT c.customerName FROM customers c WHERE c.customerNumber = p.customerNumber) AS customerName,
       p.paymentDate,
       p.amount
FROM payments p
WHERE p.amount = (SELECT MIN(amount) FROM payments);
```

| customerNumber | customerName | paymentDate | amount |
|---|---|---|---|
| 1362 | Enthusiast Diecast Direct et Fils | 2026-09-23 | 241.20 |

*1 row(s) returned.*

### C30 - Pagination - page 2

**Question:** Payments are shown 25 per page, newest first. Show page 2.  
**Skills:** ORDER BY, LIMIT, OFFSET

```sql
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
ORDER BY paymentDate DESC, customerNumber, checkNumber
LIMIT 25 OFFSET 25;
```

| customerNumber | checkNumber | paymentDate | amount |
|---|---|---|---|
| 1829 | NV250679 | 2026-09-23 | 4,236.92 |
| 2355 | UV30564 | 2026-09-23 | 35,618.06 |
| 2462 | XK108417 | 2026-09-23 | 25,114.32 |
| 495 | EJ649269 | 2026-09-22 | 12,520.43 |
| 970 | ZE365995 | 2026-09-22 | 14,066.11 |
| 1252 | JF993442 | 2026-09-22 | 10,068.81 |
| 1453 | SW820865 | 2026-09-22 | 11,569.76 |
| 1625 | PD239006 | 2026-09-22 | 23,730.10 |
| 1636 | SG55967 | 2026-09-22 | 21,446.23 |
| 1788 | PE681736 | 2026-09-22 | 22,465.87 |

*25 row(s) returned (showing first 10).*

### C31 - Very large payments

**Question:** Which customers have made at least one payment over 45,000? Show how many such payments they made.  
**Skills:** WHERE, GROUP BY, COUNT, ORDER BY, LIMIT

```sql
SELECT customerNumber, COUNT(*) AS payments_over_45k, MAX(amount) AS largest_payment
FROM payments
WHERE amount > 45000
GROUP BY customerNumber
ORDER BY payments_over_45k DESC, largest_payment DESC
LIMIT 15;
```

| customerNumber | payments_over_45k | largest_payment |
|---|---|---|
| 1048 | 1 | 60,168.04 |
| 2293 | 1 | 54,020.90 |
| 1098 | 1 | 53,547.18 |
| 1811 | 1 | 53,088.01 |
| 2419 | 1 | 52,861.81 |
| 1423 | 1 | 52,845.94 |
| 1641 | 1 | 52,441.59 |
| 2459 | 1 | 52,005.71 |
| 410 | 1 | 50,918.06 |
| 929 | 1 | 50,253.53 |

*15 row(s) returned (showing first 10).*


---

## Section D - Bonus - JOINs and business insights

### D01 - Payments by country

**Question:** How much has each country paid in total? (JOIN customers to payments)  
**Skills:** INNER JOIN, GROUP BY, SUM, COUNT

```sql
SELECT c.country,
       COUNT(p.checkNumber)    AS payments_made,
       ROUND(SUM(p.amount), 2) AS total_paid
FROM customers c
JOIN payments p ON p.customerNumber = c.customerNumber
GROUP BY c.country
ORDER BY total_paid DESC;
```

| country | payments_made | total_paid |
|---|---|---|
| USA | 4164 | 68,320,269.90 |
| Japan | 1412 | 23,206,226.88 |
| France | 1275 | 20,791,656.30 |
| Germany | 1113 | 18,540,302.64 |
| UK | 1072 | 17,190,606.93 |
| Spain | 1021 | 16,873,987.68 |
| Italy | 1015 | 16,342,963.90 |
| Australia | 901 | 14,801,438.54 |
| Canada | 614 | 10,002,664.00 |
| India | 618 | 9,945,670.28 |

*23 row(s) returned (showing first 10).*

### D02 - Top 10 customers with their sales rep

**Question:** Show the 10 biggest paying customers together with the name of their sales rep.  
**Skills:** multi-table JOIN, GROUP BY, SUM

```sql
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
```

| customerName | country | rep_first_name | rep_last_name | total_paid |
|---|---|---|---|---|
| Horizon Models GmbH | Germany | Rosa | Reyes | 884,999.70 |
| Dragon Merchants Group | USA | Rosa | Nakamura | 881,244.29 |
| Jade Collectibles Group | USA | Ben | Johnson | 837,621.91 |
| Crimson Classics B.V. | Netherlands | Mark | Dubois | 837,404.25 |
| Enthusiast Models Pty | Australia | Oscar | Iyer | 722,417.25 |
| Delta Distributors Group | USA | Sanjay | Perez | 720,910.67 |
| Diecast Collectables & Figli | Italy | Francois | Miller | 697,281.62 |
| Metro Emporium S.L. | Spain | Rosa | Reyes | 685,580.57 |
| Enthusiast Souvenirs Pte Ltd | Singapore | Rahul | Harris | 669,439.41 |
| Western Designs Pvt Ltd | India | Oscar | Iyer | 635,796.91 |

*10 row(s) returned.*

### D03 - Revenue by product line

**Question:** How many units did each product line sell and what revenue did it generate (excluding cancelled orders)?  
**Skills:** JOIN, SUM of a calculated column, GROUP BY

```sql
SELECT pr.productLine,
       SUM(od.quantityOrdered)                        AS units_sold,
       ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM orderdetails od
JOIN products pr ON pr.productCode = od.productCode
JOIN orders   o  ON o.orderNumber  = od.orderNumber
WHERE o.status <> 'Cancelled'
GROUP BY pr.productLine
ORDER BY revenue DESC;
```

| productLine | units_sold | revenue |
|---|---|---|
| Classic Cars | 896499 | 83,606,942.57 |
| Vintage Cars | 774604 | 59,404,486.83 |
| Trucks and Buses | 537068 | 54,404,456.15 |
| Planes | 559883 | 45,448,582.34 |
| Motorcycles | 402799 | 39,192,050.35 |
| Ships | 399032 | 32,065,826.90 |
| Trains | 261069 | 16,005,422.08 |

*7 row(s) returned.*

### D04 - Sales rep performance

**Question:** Which 10 sales reps have collected the most payments from their customers?  
**Skills:** JOIN, GROUP BY, SUM, COUNT DISTINCT

```sql
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
```

| employeeNumber | firstName | lastName | paying_customers | total_collected |
|---|---|---|---|---|
| 1027 | Rosa | Reyes | 152 | 19,920,815.01 |
| 1026 | Francois | Miller | 129 | 16,712,055.03 |
| 1030 | Carlos | Taylor | 121 | 16,171,076.63 |
| 1023 | Mark | Dubois | 99 | 13,481,774.16 |
| 1028 | Leila | Brown | 88 | 11,377,724.79 |
| 1036 | Oscar | Iyer | 74 | 10,771,896.67 |
| 1033 | Elena | Klein | 92 | 10,525,752.66 |
| 1024 | Matthew | Fischer | 84 | 10,436,878.26 |
| 1020 | Rosa | Nakamura | 61 | 9,419,555.38 |
| 1015 | Mei | Kim | 70 | 8,908,517.04 |

*10 row(s) returned.*

### D05 - Late shipments

**Question:** How many orders were shipped after their required date, and what share of all shipped orders is that?  
**Skills:** WHERE comparing two columns, COUNT, subquery

```sql
SELECT COUNT(*) AS late_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE shippedDate IS NOT NULL), 2) AS pct_of_shipped
FROM orders
WHERE shippedDate > requiredDate;
```

| late_orders | pct_of_shipped |
|---|---|
| 2083 | 10.88 |

*1 row(s) returned.*

### D06 - Largest orders

**Question:** What are the 10 highest-value orders?  
**Skills:** GROUP BY, SUM of a calculated column, ORDER BY, LIMIT

```sql
SELECT orderNumber,
       COUNT(*)                                       AS line_items,
       ROUND(SUM(quantityOrdered * priceEach), 2)     AS order_value
FROM orderdetails
GROUP BY orderNumber
ORDER BY order_value DESC
LIMIT 10;
```

| orderNumber | line_items | order_value |
|---|---|---|
| 10346 | 11 | 60,168.04 |
| 18680 | 10 | 55,374.87 |
| 28189 | 10 | 54,628.52 |
| 15505 | 11 | 54,101.95 |
| 26941 | 10 | 54,020.90 |
| 17043 | 11 | 53,547.18 |
| 13778 | 11 | 53,088.01 |
| 26124 | 10 | 52,861.81 |
| 27312 | 11 | 52,845.94 |
| 16810 | 8 | 52,441.59 |

*10 row(s) returned.*

### D07 - Yearly revenue trend

**Question:** What was the order revenue in each year (excluding cancelled orders)?  
**Skills:** JOIN, YEAR(), GROUP BY, SUM

```sql
SELECT YEAR(o.orderDate) AS order_year,
       COUNT(DISTINCT o.orderNumber)                    AS orders_placed,
       ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
FROM orders o
JOIN orderdetails od ON od.orderNumber = o.orderNumber
WHERE o.status <> 'Cancelled'
GROUP BY YEAR(o.orderDate)
ORDER BY order_year;
```

| order_year | orders_placed | revenue |
|---|---|---|
| 2022 | 3312 | 56,056,442.69 |
| 2023 | 3735 | 62,758,643.62 |
| 2024 | 4386 | 73,256,439.40 |
| 2025 | 4827 | 81,531,129.31 |
| 2026 | 3351 | 56,525,112.20 |

*5 row(s) returned.*

### D08 - Payment size buckets

**Question:** Group all payments into size buckets (under 5k, 5k-15k, 15k-30k, over 30k) and count them.  
**Skills:** CASE, GROUP BY, COUNT, SUM

```sql
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
```

| payment_bucket | payments_made | bucket_total |
|---|---|---|
| 1) under 5,000 | 1313 | 4,196,044.49 |
| 2) 5,000 - 14,999 | 7019 | 72,051,940.62 |
| 3) 15,000 - 29,999 | 7283 | 154,783,374.71 |
| 4) 30,000 and over | 1318 | 46,272,852.82 |

*4 row(s) returned.*

