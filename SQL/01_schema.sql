-- =====================================================================
--  ClassicModels Query Challenge  |  01_schema.sql  (MySQL 8 / MariaDB)
--  Creates the `classicmodels` database and its 8 tables.
--  Run order: 01_schema.sql -> 02_data.sql -> 03_queries.sql
-- =====================================================================

DROP DATABASE IF EXISTS classicmodels;
CREATE DATABASE classicmodels CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE classicmodels;

-- ---------------------------------------------------------------------
-- productlines : the 7 product categories
-- ---------------------------------------------------------------------
CREATE TABLE productlines (
  productLine      VARCHAR(50)   NOT NULL,
  textDescription  VARCHAR(4000) DEFAULT NULL,
  htmlDescription  MEDIUMTEXT,
  image            MEDIUMBLOB,
  PRIMARY KEY (productLine)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- products : every model in the catalogue
-- ---------------------------------------------------------------------
CREATE TABLE products (
  productCode         VARCHAR(15)   NOT NULL,
  productName         VARCHAR(70)   NOT NULL,
  productLine         VARCHAR(50)   NOT NULL,
  productScale        VARCHAR(10)   NOT NULL,
  productVendor       VARCHAR(50)   NOT NULL,
  productDescription  TEXT          NOT NULL,
  quantityInStock     SMALLINT      NOT NULL,
  buyPrice            DECIMAL(10,2) NOT NULL,
  MSRP                DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (productCode),
  KEY idx_products_line (productLine),
  CONSTRAINT products_ibfk_1 FOREIGN KEY (productLine) REFERENCES productlines (productLine)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- offices : company sales offices
-- ---------------------------------------------------------------------
CREATE TABLE offices (
  officeCode   VARCHAR(10) NOT NULL,
  city         VARCHAR(50) NOT NULL,
  phone        VARCHAR(50) NOT NULL,
  addressLine1 VARCHAR(50) NOT NULL,
  addressLine2 VARCHAR(50) DEFAULT NULL,
  state        VARCHAR(50) DEFAULT NULL,
  country      VARCHAR(50) NOT NULL,
  postalCode   VARCHAR(15) NOT NULL,
  territory    VARCHAR(10) NOT NULL,
  PRIMARY KEY (officeCode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- employees : staff, including sales reps (reportsTo = self-reference)
-- ---------------------------------------------------------------------
CREATE TABLE employees (
  employeeNumber INT          NOT NULL,
  lastName       VARCHAR(50)  NOT NULL,
  firstName      VARCHAR(50)  NOT NULL,
  extension      VARCHAR(10)  NOT NULL,
  email          VARCHAR(100) NOT NULL,
  officeCode     VARCHAR(10)  NOT NULL,
  reportsTo      INT          DEFAULT NULL,
  jobTitle       VARCHAR(50)  NOT NULL,
  PRIMARY KEY (employeeNumber),
  KEY idx_emp_reportsTo (reportsTo),
  KEY idx_emp_office (officeCode),
  CONSTRAINT employees_ibfk_1 FOREIGN KEY (reportsTo)  REFERENCES employees (employeeNumber),
  CONSTRAINT employees_ibfk_2 FOREIGN KEY (officeCode) REFERENCES offices (officeCode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- customers : B2B customers, each optionally assigned to a sales rep
-- ---------------------------------------------------------------------
CREATE TABLE customers (
  customerNumber         INT           NOT NULL,
  customerName           VARCHAR(50)   NOT NULL,
  contactLastName        VARCHAR(50)   NOT NULL,
  contactFirstName       VARCHAR(50)   NOT NULL,
  phone                  VARCHAR(50)   NOT NULL,
  addressLine1           VARCHAR(50)   NOT NULL,
  addressLine2           VARCHAR(50)   DEFAULT NULL,
  city                   VARCHAR(50)   NOT NULL,
  state                  VARCHAR(50)   DEFAULT NULL,
  postalCode             VARCHAR(15)   DEFAULT NULL,
  country                VARCHAR(50)   NOT NULL,
  salesRepEmployeeNumber INT           DEFAULT NULL,
  creditLimit            DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (customerNumber),
  KEY idx_cust_salesRep (salesRepEmployeeNumber),
  KEY idx_cust_country (country),
  CONSTRAINT customers_ibfk_1 FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees (employeeNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- orders : one row per sales order
-- ---------------------------------------------------------------------
CREATE TABLE orders (
  orderNumber    INT         NOT NULL,
  orderDate      DATE        NOT NULL,
  requiredDate   DATE        NOT NULL,
  shippedDate    DATE        DEFAULT NULL,
  status         VARCHAR(15) NOT NULL,
  comments       TEXT,
  customerNumber INT         NOT NULL,
  PRIMARY KEY (orderNumber),
  KEY idx_orders_customer (customerNumber),
  KEY idx_orders_date (orderDate),
  CONSTRAINT orders_ibfk_1 FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- orderdetails : line items of each order
-- ---------------------------------------------------------------------
CREATE TABLE orderdetails (
  orderNumber     INT           NOT NULL,
  productCode     VARCHAR(15)   NOT NULL,
  quantityOrdered INT           NOT NULL,
  priceEach       DECIMAL(10,2) NOT NULL,
  orderLineNumber SMALLINT      NOT NULL,
  PRIMARY KEY (orderNumber, productCode),
  KEY idx_od_product (productCode),
  CONSTRAINT orderdetails_ibfk_1 FOREIGN KEY (orderNumber) REFERENCES orders (orderNumber),
  CONSTRAINT orderdetails_ibfk_2 FOREIGN KEY (productCode) REFERENCES products (productCode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- payments : customer payments (one row per cheque / transfer)
-- ---------------------------------------------------------------------
CREATE TABLE payments (
  customerNumber INT           NOT NULL,
  checkNumber    VARCHAR(50)   NOT NULL,
  paymentDate    DATE          NOT NULL,
  amount         DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (customerNumber, checkNumber),
  KEY idx_pay_date (paymentDate),
  CONSTRAINT payments_ibfk_1 FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
