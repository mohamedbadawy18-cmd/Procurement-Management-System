With Monthly_Spend As (
     select
          YEAR(Order_Date) AS Order_Year,
		  MONTH(Order_Date) As Order_Month,
		  SUM(Amount) As Total_Spend

     from purchase_orders
     group by YEAR(Order_Date), MONTH(Order_Date)
)
select 
      Order_Year,
	  Order_Month,
	  Total_Spend,
	  LAG(Total_Spend) OVER (ORDER BY Order_Year, Order_Month) AS Previous_Month_Spend,
	  ROUND((Total_Spend - LAG(Total_Spend) OVER (ORDER BY Order_Year, Order_Month)) * 100.0 
        / LAG(Total_Spend) OVER (ORDER BY Order_Year, Order_Month), 2
    ) AS Pct_Change_From_Prev_Month

from Monthly_Spend
order by Order_Year, Order_Month;



-- ‰”»… «· —«Ã⁄ „‰ ﬁ„… ÌÊ‰ÌÊ ·ﬁ⁄— ”» „»— 2021
SELECT 
    ROUND((9812786.78 - 11782892.44) * 100.0 / 11782892.44, 2) AS Jun_to_Jul,
    ROUND((2366370.56 - 11782892.44) * 100.0 / 11782892.44, 2) AS Jun_to_Sep_Total_Drop;