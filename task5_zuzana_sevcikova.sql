/*
 * otazka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, 
 * pokud HDP vzroste výrazněji v jednom roce, projeví se to na 
 * cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

 Jmeno: Zuzana Ševčíková
uzivatelske jmeno na Discordu: Zuzana Š.
uzivatelske jmeno na GitHubu: ZuzkaSG
 */

-- -> =============================================================================================

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
		) AS bb	-- rozdelenie tabulky, znizenie poctu riadkov, aby v nadradenom selekte fungoval GROUP BY 
	GROUP BY bb.payroll_year
	) AS bc -- 13 riadkov
),
cte_zs_task55 AS (	-- priprava zdrojovych dat GDP
SELECT cc.`year`, cc.GDP,
	lag(cc.GDP) OVER (ORDER BY cc.`year`) AS previous_year_GDP,
	round(((cc.GDP - lag(cc.GDP) OVER (ORDER BY cc.`year`)) /
		lag(cc.GDP) OVER (ORDER BY cc.`year`) *100), 2)
		AS annual_GDP_increase_percent
FROM (		
	SELECT DISTINCT tz.`year`, tz.GDP  -- rozdelenie tabulky, znizenie poctu riadkov
	FROM t_zuzana_sevcikova_project_sql_primary_final tz  
	)AS cc -- 13 riadkov
)
SELECT cte3.`year`, cte5.annual_GDP_increase_percent, cte3.annual_price_increase_percent, 
	cte4.annual_payroll_increase_percent
FROM cte_zs_task43 cte3
JOIN cte_zs_task44 cte4 ON cte3.`year` = cte4.payroll_year
JOIN cte_zs_task55 cte5 ON cte5.`year` = cte3.`year` ;

-- <- ======================================================================================================

