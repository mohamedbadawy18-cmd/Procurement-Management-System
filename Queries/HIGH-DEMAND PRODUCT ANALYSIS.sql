With Product_Demond As (
     select
           p.Product_Name, 
           p.Category,
           SUM(po.Quantity) AS Total_Q_Ordered,
           SUM(po.Amount) AS Total_Spend

     from purchase_orders po
     Join products p ON po.Product_ID = p.Product_ID
     group by p.Product_Name, p.Category
)
select 
      Product_Name,
      Category,
      Total_Q_Ordered,
      Total_Spend,
      ROUND(Total_Q_Ordered * 100.0 / (SELECT SUM(Quantity) FROM purchase_orders), 2) AS Pct_Of_Total_Volume
from Product_Demond
order by Total_Q_Ordered Desc;