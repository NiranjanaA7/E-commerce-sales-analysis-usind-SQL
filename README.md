# 🛒 E-Commerce Analytics Dashboard

### End-to-End Data Analytics Project | SQL → Power BI → DAX

## 📌 Project Overview

An end-to-end e-commerce analytics project that takes a relational SQL dataset (Customers, Orders, Products, Sales) through to a fully interactive Power BI dashboard. The project demonstrates the same analytical logic implemented twice — once in SQL, once in DAX — to show both skill sets working toward the same business questions.

```text
Raw E-Commerce Dataset
        ↓
SQL Database (4 tables, 13 queries, 4 views)
        ↓
Power BI Import
        ↓
Star Schema Data Model
        ↓
DAX Measures + Date Table
        ↓
3-Page Interactive Dashboard
```

---

## 🎯 Business Problem

An e-commerce business generates data across customers, orders, products, and transactions. This project turns that raw data into decision-ready insights, answering questions such as:

- How much revenue is the business generating, and is it growing month over month?
- Which customers and products drive the most revenue?
- How are customers distributed across spending segments, gender, and age?
- Who is the top customer in each state?
- Which product categories and individual products perform best?
- How does price relate to quantity sold?

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| SQL | Table design, joins, CTEs, window functions, views |
| Power BI | Data modeling, DAX, dashboard design |
| DAX | Measures, time intelligence, ranking, segmentation |
| Power Query | Data loading and transformation |

---

## 🗄️ Database Design

Four relational tables with primary/foreign key relationships:

```text
Customers ──customer_id──► Orders ──order_id──► Sales ◄──product_id── Products
```

- **Customers**: customer_id, customer_name, gender, age, city, state, country
- **Orders**: order_id, customer_id, payment, order_date, delivery_date
- **Products**: product_id, product_type, product_name, size, colour, price
- **Sales**: sales_id, order_id, product_id, price_per_unit, quantity, total_price

---

## 🔍 SQL Analysis

13 analytical queries covering joins, a CTE-based customer segmentation model, and window functions:

```sql
RANK()        -- customer spending rank
DENSE_RANK()  -- product ranking
ROW_NUMBER()  -- top customer per state (PARTITION BY state)
LAG()         -- previous month revenue
SUM() OVER()  -- running revenue
```

Four reusable views were also built (`vw_monthly_sales`, `vw_customer_summary`, `vw_product_summary`, `vw_kpi_summary`) and used as a **QA/validation layer** — see [Key Decisions](#-key-decisions) below.

---

## ⭐ Power BI Data Model

A star schema was built using the **raw tables**, not the SQL views — this was a deliberate design decision (explained below).

```text
                 DateTable
                     │
                     ▼
Customers ───► Orders ───► Sales ◄─── Products
```

- One-to-many, single-direction relationships
- Dedicated `DateTable` built via `CALENDAR()`, marked as an official Date Table to support time intelligence
- Dataset spans **January 2021 – October 2021**

---

## 🧮 Key DAX Measures

```DAX
Total Revenue = SUM(Sales[total_price])

Active Customers = DISTINCTCOUNT(Orders[customer_id])

Average Order Value = DIVIDE([Total Revenue], [Total Orders])

Running Revenue =
CALCULATE(
    [Total Revenue],
    FILTER(ALLSELECTED(DateTable), DateTable[Date] <= MAX(DateTable[Date]))
)

Previous Month Revenue =
CALCULATE([Total Revenue], DATEADD(DateTable[Date], -1, MONTH))

MoM Growth % =
DIVIDE([Total Revenue] - [Previous Month Revenue], [Previous Month Revenue])

Product Rank =
RANKX(ALL(Products[product_name]), [Total Revenue], , DESC, Dense)

Spending Category =
SWITCH(
    TRUE(),
    [Total Revenue] > 3000, "High Spender",
    [Total Revenue] >= 1000, "Medium Spender",
    "Low Spender"
)
```

### SQL → DAX Mapping

| Business Logic | SQL | Power BI / DAX |
|---|---|---|
| Running Revenue | `SUM() OVER()` | `Running Revenue` |
| Month-over-Month | `LAG()` | `Previous Month Revenue`, `MoM Growth %` |
| Product Ranking | `DENSE_RANK()` | `Product Rank` |
| Customer Segmentation | `CASE` + `RANK()` | `Spending Category` |
| Top Customer per State | `ROW_NUMBER()` + `PARTITION BY` | Table visual, ranked by state |

---

## 🎨 Key Decisions

**Why raw tables instead of SQL views for the data model?**
The four SQL views are pre-aggregated, which freezes their grain and blocks re-slicing by filters like date range or product type. Row-level detail (needed for future drillthrough) only exists in the raw `Sales` table. The views were kept in the SQL script and used to cross-check DAX measure totals as a validation step, rather than feeding the model directly.

**Design system**: consistent dark-mode theme, custom "Vintage Violet" palette (`#9F5F9F`, `#C8A2C8`, `#8A496B`, `#DABFD4`, `#7C5C6F`), applied via a shared Power BI theme file across all pages.

---

## 📈 Dashboard Pages

### 1️⃣ Executive Summary
High-level business health at a glance.
- KPI row: Total Revenue, Total Orders, Average Order Value, Active Customers, MoM Growth %
- Revenue & Running Revenue trend (dual-axis line chart)
- Revenue by Product Type
- Revenue by State
- MonthYear slicer

### 2️⃣ Customer Analytics
Who buys, and who matters most.
- Top 10 Customers by Revenue
- Gender Distribution
- Customer Spending Segments (High / Medium / Low)
- Customer Age Distribution
- Top Customer per State (table — direct output of the SQL `ROW_NUMBER()` + `PARTITION BY` query)

### 3️⃣ Product Analytics
What's driving performance on the product side.
- Top 10 Products by Revenue
- Product Performance Ranking (table with `Product Rank`)
- Quantity vs Revenue by Product
- Revenue by Product Category

### 4️⃣ Customer Drillthrough — *Coming soon*
A planned drillthrough page for per-customer order history and purchase detail.

---

## 📷 Dashboard Preview

```text
images/
├── executive-summary.png
├── customer-analytics.png
└── product-analytics.png
```

```md
## Executive Summary
![Executive Summary](img/executive-summary.png)

## Customer Analytics
![Customer Analytics](img/customer-analytics.png)

## Product Analytics
![Product Analytics](img/product-analytics.png)
```

---

## 📁 Project Structure

```text
E-Commerce-Analytics-Project
│
├── SQL
│   └── ecommerce_analysis.sql
│
├── PowerBI
│   └── E-Commerce_Analytics_Dashboard.pbix
│
├── images
│   ├── executive-summary.png
│   ├── customer-analytics.png
│   └── product-analytics.png
│
└── README.md
```

---

## 🚀 Planned Next Steps

- Customer drillthrough page (order history, purchase detail)
- Bookmark-based page navigation
- RFM customer segmentation
- Field parameters / metric toggle
- Power BI Service publishing

---

## 💼 Skills Demonstrated

```text
SQL · Joins · CTEs · Window Functions · SQL Views
Power BI · Data Modeling · Star Schema · DAX · Time Intelligence
Data Visualization · Business Analysis · Dashboard Design
```

---

> An end-to-end e-commerce analytics project demonstrating the full workflow from relational SQL analysis through Power BI data modeling, DAX, and interactive dashboard design across customer, product, and executive-level views.
