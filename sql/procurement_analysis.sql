/* ============================================================
   PROCUREMENT MANAGEMENT SYSTEM — SQL ANALYSIS
   Database: ProcurementDB (SQL Server)
   Tables: purchase_orders (23,150 rows), vendors (30), 
           products (36), inventory (36)
   ============================================================ */


/* ------------------------------------------------------------
   QUERY 1 — VENDOR CONCENTRATION RISK
   Ranks all vendors by total spend and calculates each 
   vendor's share of overall procurement spend.
   Technique: CTE + Window Function (RANK)
   ------------------------------------------------------------ */

USE ProcurementDB;

WITH VendorSpend AS (
    SELECT 
        v.Vendor_Name,
        SUM(po.Amount) AS Total_Spend,
        COUNT(po.Order_ID) AS Total_Orders
    FROM purchase_orders po
    JOIN vendors v ON po.Vendor_ID = v.Vendor_ID
    GROUP BY v.Vendor_Name
),
RankedVendors AS (
    SELECT 
        Vendor_Name,
        Total_Spend,
        Total_Orders,
        RANK() OVER (ORDER BY Total_Spend DESC) AS Spend_Rank
    FROM VendorSpend
)
SELECT 
    Vendor_Name,
    Total_Orders,
    Total_Spend,
    Spend_Rank,
    ROUND(Total_Spend * 100.0 / (SELECT SUM(Amount) FROM purchase_orders), 2) AS Pct_Of_Total_Spend
FROM RankedVendors
ORDER BY Spend_Rank;

/* RESULT: Top 3 vendors (Apex Industrial Supplies, Gulf Trading Co.,
   Falcon Hardware LLC) represent 38.07% of total procurement spend
   across only 3 of 30 vendors (10% of the vendor base). */


/* ------------------------------------------------------------
   QUERY 2 — HIGH-DEMAND PRODUCT ANALYSIS
   Identifies which products drive the highest order volume,
   to prioritize high-impact SKUs for inventory management.
   Technique: CTE + Aggregation + Subquery
   ------------------------------------------------------------ */

WITH Product_Demand AS (
    SELECT
        p.Product_Name, 
        p.Category,
        SUM(po.Quantity) AS Total_Q_Ordered,
        SUM(po.Amount) AS Total_Spend
    FROM purchase_orders po
    JOIN products p ON po.Product_ID = p.Product_ID
    GROUP BY p.Product_Name, p.Category
)
SELECT 
    Product_Name,
    Category,
    Total_Q_Ordered,
    Total_Spend,
    ROUND(Total_Q_Ordered * 100.0 / (SELECT SUM(Quantity) FROM purchase_orders), 2) AS Pct_Of_Total_Volume
FROM Product_Demand
ORDER BY Total_Q_Ordered DESC;

/* RESULT: The top 4 products (Packing Tape, Desktop Computers, 
   Aluminum Rods, Office Chairs) account for 49.67% of total 
   order volume — just 11% of the 36-product catalog. */


/* ------------------------------------------------------------
   QUERY 3 — INVENTORY GAP DETECTION
   Flags products where current stock has fallen below the
   reorder threshold, classified by urgency level.
   Technique: CASE WHEN + Calculated Ratios
   ------------------------------------------------------------ */

SELECT 
    Product_Name,
    Category,
    Stock_Level,
    Reorder_Threshold,
    (Reorder_Threshold - Stock_Level) AS Units_Below_Threshold,
    CASE 
        WHEN Stock_Level < Reorder_Threshold THEN 'CRITICAL - Reorder Needed'
        WHEN Stock_Level < Reorder_Threshold * 1.2 THEN 'LOW - Monitor Closely'
        ELSE 'Healthy'
    END AS Stock_Status
FROM inventory
ORDER BY (CAST(Stock_Level AS FLOAT) / Reorder_Threshold) ASC;

/* RESULT: 7 of 36 products (19.4%) are in CRITICAL status. 
   Work Gloves shows the largest gap at 229 units below threshold. */


/* ------------------------------------------------------------
   QUERY 4 — MONTHLY SPENDING TREND ANALYSIS
   Tracks month-over-month spending changes to identify
   seasonal demand patterns and volatility.
   Technique: Window Function (LAG)
   ------------------------------------------------------------ */

WITH MonthlySpend AS (
    SELECT 
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,
        SUM(Amount) AS Total_Spend
    FROM purchase_orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT 
    Order_Year,
    Order_Month,
    Total_Spend,
    LAG(Total_Spend) OVER (ORDER BY Order_Year, Order_Month) AS Previous_Month_Spend,
    ROUND(
        (Total_Spend - LAG(Total_Spend) OVER (ORDER BY Order_Year, Order_Month)) * 100.0 
        / LAG(Total_Spend) OVER (ORDER BY Order_Year, Order_Month), 2
    ) AS Pct_Change_From_Prev_Month
FROM MonthlySpend
ORDER BY Order_Year, Order_Month;

/* RESULT: Spending peaked in June 2021 ($11.78M) then dropped 
   sharply through Q3, bottoming out in September 2021 ($2.37M) 
   — a cumulative peak-to-trough decline of -79.92%. */


/* ------------------------------------------------------------
   QUERY 5 — VENDOR STABILITY OVER TIME (Year-over-Year)
   Ranks vendors by spend within each year separately to check
   whether the top vendors remain consistent or shift over time.
   Technique: Window Function with PARTITION BY
   ------------------------------------------------------------ */

WITH YearlyVendorSpend AS (
    SELECT 
        v.Vendor_Name,
        YEAR(po.Order_Date) AS Order_Year,
        SUM(po.Amount) AS Yearly_Spend
    FROM purchase_orders po
    JOIN vendors v ON po.Vendor_ID = v.Vendor_ID
    GROUP BY v.Vendor_Name, YEAR(po.Order_Date)
),
RankedByYear AS (
    SELECT 
        Vendor_Name,
        Order_Year,
        Yearly_Spend,
        RANK() OVER (PARTITION BY Order_Year ORDER BY Yearly_Spend DESC) AS Rank_In_Year
    FROM YearlyVendorSpend
)
SELECT 
    Vendor_Name,
    Order_Year,
    Yearly_Spend,
    Rank_In_Year
FROM RankedByYear
WHERE Rank_In_Year <= 3
ORDER BY Order_Year, Rank_In_Year;

/* RESULT: The same 3 vendors (Apex Industrial Supplies, Gulf 
   Trading Co., Falcon Hardware LLC) held the top 3 spend ranks 
   in every single year from 2021-2024 — confirming the 
   concentration risk is a persistent structural pattern, 
   not a one-time anomaly. */
