select 
      Product_Name,
	  Category,
	  Stock_Level,
	  Reorder_Threshold,
	  (Reorder_Threshold - Stock_Level) AS Units_Below_Threshold,
	  CASE 
	      WHEN Stock_Level < Reorder_Threshold THEN 'CRITICAL - Reorder Needed'
		  WHEN Stock_Level < Reorder_Threshold*1.2 THEN 'LOW - Monitor Closely'
		  ELSE 'Healthy'
	  END AS Stock_Status

from inventory
ORDER BY (CAST(Stock_Level AS FLOAT) / Reorder_Threshold) ASC;