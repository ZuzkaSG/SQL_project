/*
 * otazka 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst 
 * mezd (větší než 10 %)?
 
 - region_code (resp. region_name) IS NULL pre CR cenovy priemer potravinovych kategorii
 - tab cz_payroll je celorepublikovym priemerom miezd
 - group by vrati unikatne kombinacie riadkov, select distinct potom straca zmysel
 */
-- -> ===================(verzia 1)==========================================================================

WITH cte_zs_task41 AS ( -- priprava zdrojovych dat cien
	SELECT tz.avg_price , tz.food_category, tz.`year`, -- 342 riadkov
		lag(tz.avg_price) OVER (PARTITION BY tz.food_category ORDER BY tz.`year`) 
		AS previous_year_avg_price,
		round(((tz.avg_price - lag(tz.avg_price) OVER (PARTITION BY tz.food_category ORDER BY tz.`year`)) /
		lag(tz.avg_price) OVER (PARTITION BY tz.food_category ORDER BY tz.`year`) *100), 2)
		AS annual_price_increase_percent
	FROM t_zuzana_sevcikova_project_sql_primary_final tz 
	WHERE region_name IS NULL -- IS NULL pre CR cenovy priemer potravinovych kategorii
	GROUP BY tz.food_category, tz.`year`
),
cte_zs_task42 AS (	-- priprava zdrojovych dat miezd
	SELECT  tz.year_averaged_payroll_CZK, tz.industry_branch, tz.payroll_year, -- 247 riadkov
		lag(tz.year_averaged_payroll_CZK) OVER (PARTITION BY tz.industry_branch ORDER BY tz.payroll_year) 
		AS previous_year_avg_payroll,
		round(((tz.year_averaged_payroll_CZK - lag(tz.year_averaged_payroll_CZK) OVER 
		(PARTITION BY tz.industry_branch ORDER BY tz.payroll_year)) /
		lag(tz.year_averaged_payroll_CZK) OVER (PARTITION BY tz.industry_branch ORDER BY tz.payroll_year)
		*100), 2)
		AS annual_payroll_increase_percent	
	FROM t_zuzana_sevcikova_project_sql_primary_final tz
	GROUP BY tz.industry_branch, tz.payroll_year
)
SELECT *
FROM (
	SELECT cte1.food_category, cte1.`year`, cte1.annual_price_increase_percent,
		cte2.industry_branch, cte2.payroll_year, cte2.annual_payroll_increase_percent,
		CASE WHEN (cte1.annual_price_increase_percent - cte2.annual_payroll_increase_percent) > 10
			THEN 1 ELSE 0 
		END AS is_higher_10percent
	FROM cte_zs_task41 cte1
	JOIN cte_zs_task42 cte2 
		ON cte1.`year` = cte2.payroll_year AND cte1.annual_price_increase_percent IS NOT NULL 
			AND cte2.annual_payroll_increase_percent IS NOT NULL 
	) AS pp
WHERE pp.is_higher_10percent = 1
;	

-- <- =======================================================================================================
-- -> ===================(verzia 2)==========================================================================

WITH cte_zs_task43 AS ( -- priprava zdrojovych dat cien
SELECT ab.`year`, ab.yearly_pricelist_average, 
	lag(ab.yearly_pricelist_average) OVER (ORDER BY ab.`year`) AS previous_yearly_pricelist_average,
	round(((ab.yearly_pricelist_average - lag(ab.yearly_pricelist_average) OVER (ORDER BY ab.`year`)) /
		lag(ab.yearly_pricelist_average) OVER (ORDER BY ab.`year`) *100), 2)
		AS annual_price_increase_percent
FROM (
	SELECT aa.`year`, avg(aa.avg_price) AS yearly_pricelist_average, count(1)
	FROM (
		SELECT DISTINCT tz.`year`, tz.food_category, tz.avg_price  
		FROM t_zuzana_sevcikova_project_sql_primary_final tz 
		WHERE tz.region_name IS NULL 
		)AS aa -- rozdelenie tabulky, znizenie poctu riadkov, aby v nadradenom selekte fungoval GROUP BY 
	GROUP BY aa.`year`
	) AS ab -- 13 riadkov
),
cte_zs_task44 AS (	-- priprava zdrojovych dat miezd
SELECT bc.payroll_year , bc.yearly_average_payroll, 
	lag(bc.yearly_average_payroll) OVER (ORDER BY bc.payroll_year) AS previous_yearly_average_payroll,
	round(((bc.yearly_average_payroll - lag(bc.yearly_average_payroll) OVER (ORDER BY bc.payroll_year)) /
		lag(bc.yearly_average_payroll) OVER (ORDER BY bc.payroll_year) *100), 2)
		AS annual_payroll_increase_percent
FROM (
	SELECT bb.payroll_year , avg(bb.year_averaged_payroll_CZK) AS yearly_average_payroll,
		count(1)
	FROM (
		SELECT DISTINCT tz.payroll_year , tz.industry_branch , tz.year_averaged_payroll_CZK 
		FROM t_zuzana_sevcikova_project_sql_primary_final tz 
		) AS bb	-- rozdelenie tabulky, znizenie poctu riadkov, aby v nadradenom selecte fungoval GROUP BY 
	GROUP BY bb.payroll_year
	) AS bc -- 13 riadkov
)
SELECT cte3.`year`, cte3.annual_price_increase_percent, cte4.annual_payroll_increase_percent,
	CASE WHEN (cte3.annual_price_increase_percent - cte4.annual_payroll_increase_percent) > 10
		THEN 1 ELSE 0 
	END AS is_higher_10percent
FROM cte_zs_task43 cte3
JOIN cte_zs_task44 cte4 ON cte3.`year` = cte4.payroll_year;

-- <- ======================================================================================================


