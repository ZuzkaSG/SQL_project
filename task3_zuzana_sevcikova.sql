/*
 * otázka 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

-- -> ==========================================================================================================================

WITH cte_zs_task3 AS ( -- priprava zdrojovych dat
	SELECT DISTINCT avg_price , food_category, `year`
	FROM t_zuzana_sevcikova_project_sql_primary_final tz 
	WHERE region_name IS NULL 	-- region_code (resp. region_name) IS NULL pre CR cenovy priemer potravinovych kategorii
)  -- vypoctova CAST:
SELECT aa.food_category,
	round(((aa.annual_price_increase_percent + aa.`annualm1_price_increase_percent` + aa.`annualm2_price_increase_percent`) / 3), 2) 
	AS avg_annual_price_incr_percent
FROM (
SELECT 
	cte1.avg_price, cte1.food_category, cte1.`year`,
	cte2.avg_price AS `yearm1_avg_price`, cte2.`year` AS `yearm1`,
	round(((cte1.avg_price - cte2.avg_price) / cte2.avg_price *100), 2) AS annual_price_increase_percent,
	cte3.avg_price AS `yearm2_avg_price`, cte3.`year` AS `yearm2`,
	round(((cte2.avg_price - cte3.avg_price) / cte3.avg_price *100), 2) AS `annualm1_price_increase_percent`,
	cte4.avg_price AS `yearm3_avg_price`, cte4.`year` AS `yearm3`,
	round(((cte3.avg_price - cte4.avg_price) / cte4.avg_price *100), 2) AS `annualm2_price_increase_percent`
FROM cte_zs_task3 cte1
JOIN cte_zs_task3 cte2
	ON cte1.food_category = cte2.food_category AND cte1.`year` = cte2.`year` + 1 AND cte1.`year` = 2018
JOIN cte_zs_task3 cte3
	ON cte1.food_category = cte3.food_category AND cte1.`year` = cte3.`year` + 2 
JOIN cte_zs_task3 cte4
	ON cte1.food_category = cte4.food_category AND cte1.`year` = cte4.`year` + 3 
) AS aa	
GROUP BY aa.food_category
ORDER BY avg_annual_price_incr_percent desc;





