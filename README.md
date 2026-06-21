#  Procurement Management System — SQL Analysis
> Uncovering vendor concentration risk, demand patterns, and inventory gaps across 23,150 purchase orders

---

##  Project Overview

| | |
|---|---|
| **Industry** | Procurement / Supply Chain |
| **Tool** | Microsoft SQL Server (T-SQL) |
| **Dataset Size** | 23,150 purchase orders · 30 vendors · 36 products · 5 years |
| **Type** | Portfolio Project |

---

## 🎯 Business Problem

A company managing 23,000+ purchase orders across 30 vendors and 36 products needed to answer:

1. Is procurement spend dangerously concentrated in a small number of vendors?
2. Which products drive the most order volume, and should be prioritized for inventory planning?
3. Which products are at risk of stockouts right now?
4. Are there seasonal spending patterns that procurement teams should plan around?
5. Is vendor concentration a one-time event, or a persistent structural risk?

---

##  Data Model

```
        purchase_orders (Fact — 23,150 rows)
                    ↓
        ┌───────────┼───────────┐
        ↓                       ↓
    vendors (30)            products (36) ──── inventory (36)
```

| Table | Rows | Key Fields |
|---|---|---|
| `purchase_orders` | 23,150 | Order_ID, Order_Date, Vendor_ID, Product_ID, Quantity, Unit_Price, Amount |
| `vendors` | 30 | Vendor_ID, Vendor_Name |
| `products` | 36 | Product_ID, Product_Name, Category |
| `inventory` | 36 | Product_ID, Stock_Level, Reorder_Threshold |

---

##  SQL Techniques Used

- **CTEs (Common Table Expressions)** — breaking complex logic into readable steps
- **Window Functions** — `RANK()`, `RANK() OVER (PARTITION BY ...)`, `LAG()`
- **CASE WHEN** — multi-tier business logic classification
- **Subqueries** — calculating percentage-of-total metrics
- **Aggregate functions** — `SUM`, `COUNT` across multi-table joins
- **Date functions** — `YEAR()`, `MONTH()` for time-series analysis

Full queries with comments: [`sql/procurement_analysis.sql`](sql/procurement_analysis.sql)

---

##  Key Findings

| # | Finding | Data |
|---|---|---|
| 1 | **Vendor concentration risk** | Top 3 vendors (10% of vendor base) account for **38.07%** of total spend |
| 2 | **Single-vendor exposure** | Apex Industrial Supplies alone represents **18.02%** of all procurement spend |
| 3 | **High-demand SKU concentration** | Top 4 products (11% of catalog) drive **49.67%** of total order volume |
| 4 | **Inventory gaps** | **7 of 36 products (19.4%)** are below reorder threshold — Work Gloves short by 229 units |
| 5 | **Seasonal volatility** | Spending swung from a **$11.78M peak** (Jun 2021) to a **$2.37M trough** (Sep 2021) — a **79.92%** decline |
| 6 | **Persistent risk pattern** | The same top 3 vendors ranked #1, #2, #3 in **every year from 2021–2024** — confirming concentration is structural, not incidental |

---

##  Query Breakdown

### 1. Vendor Concentration Risk
Ranks all 30 vendors by total spend using `RANK()`, calculating each vendor's share of overall spend via a correlated subquery.

### 2. High-Demand Product Analysis
Aggregates order volume per product to surface the highest-impact SKUs — critical for prioritizing inventory and negotiation leverage.

### 3. Inventory Gap Detection
Classifies all 36 products into **Critical / Low / Healthy** stock tiers using `CASE WHEN` logic comparing current stock to reorder thresholds.

### 4. Monthly Spending Trend Analysis
Uses `LAG()` to compute month-over-month percentage change, revealing a sharp mid-year spending spike followed by a steep Q3 decline.

### 5. Vendor Stability Over Time
Uses `RANK() OVER (PARTITION BY Order_Year ...)` to re-rank vendors *within each year independently* — confirming the same vendors dominate spend year after year.

---

##  Recommendations

### 1.  Diversify the Vendor Base
With 38% of spend concentrated in 3 vendors — unchanged for 4 consecutive years — the business should qualify 2-3 alternative suppliers for high-spend categories to reduce single-source dependency risk.

### 2.  Prioritize High-Volume SKUs in Negotiations
Since just 4 products drive half of all order volume, securing better pricing or bulk terms on these specific SKUs would have outsized impact on total procurement costs.

### 3.  Address Critical Stock Gaps Immediately
7 products are currently below reorder threshold. Automating reorder alerts at the threshold level (rather than manual tracking) would prevent stockouts on high-impact items like Work Gloves and Junction Boxes.

### 4.  Plan Procurement Cycles Around Seasonal Demand
The ~80% spend swing between Q2 and Q3 suggests procurement planning should account for seasonal demand cycles — potentially negotiating flexible delivery schedules with top vendors to match this pattern.

---

##  Repository Structure

```
├── README.md
├── sql/
│   └── procurement_analysis.sql      ← All 5 queries with comments
└── data/
    ├── purchase_orders.csv
    ├── vendors.csv
    ├── products.csv
    └── inventory.csv
```

---

##  Tools Used

- **Microsoft SQL Server (SSMS)** — Database design, query development, execution
- **T-SQL** — CTEs, window functions, conditional logic, time-series aggregation

---

##  About

This project simulates a real-world procurement analytics scenario, using a synthetically generated dataset modeled on realistic vendor concentration, demand distribution, and seasonal spending patterns. Built end-to-end: database design, data import, and advanced SQL analysis.

📧 [mohamedbadawisayed@gmail.com] | 💼 [www.linkedin.com/in/mohamed-badawi28] | 🐙 [https://github.com/mohamedbadawy18-cmd]
