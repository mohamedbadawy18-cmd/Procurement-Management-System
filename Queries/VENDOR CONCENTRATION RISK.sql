With Vendor_Spend As (

     select
           v.Vendor_Name, 
           SUM(po.Amount) As Total_Spend,
           COUNT(po.Order_ID) As Total_Orders

     from purchase_orders po
     Join vendors v ON po.Vendor_ID = v.Vendor_ID
     group by v.Vendor_Name
),
Ranked_Vendors AS (
     select 
	       Vendor_Name,
		   Total_Spend,
		   Total_Orders,
		   RANK() OVER (ORDER BY Total_Spend Desc) AS Spend_Rank

	 from Vendor_Spend
)

select 
      Vendor_Name,
	  Total_Spend,
	  Total_Orders,
	  Spend_Rank,
	  ROUND((Total_Spend / (SELECT SUM(Amount) FROM purchase_orders))* 100, 2) AS Pct_Of_Total_Spend

from Ranked_Vendors
order by Spend_Rank;
