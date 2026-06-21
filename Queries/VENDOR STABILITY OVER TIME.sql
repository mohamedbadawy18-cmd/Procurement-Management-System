With Yearly_Vendors_Spend As (

     select
           v.Vendor_Name, 
		   YEAR(po.Order_Date) AS Order_Year,
           SUM(po.Amount) As Yearly_Spend

     from purchase_orders po
     Join vendors v ON po.Vendor_ID = v.Vendor_ID
     group by v.Vendor_Name, YEAR(po.Order_Date)
),
Ranked_By_Year AS (
     select 
	       Vendor_Name,
		   Order_Year,
		   Yearly_Spend,
		   RANK() OVER(PARTITION BY Order_Year ORDER BY Yearly_Spend DESC) AS Rank_In_Year

	 from Yearly_Vendors_Spend
)

select 
      Vendor_Name,
	  Order_Year,
	  Yearly_Spend,
	  Rank_In_Year

from Ranked_By_Year
where Rank_In_Year <= 3
order by Order_Year, Rank_In_Year;
