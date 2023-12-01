/* -> ==========================================================================================
 * Prva tabulka:
 * 
 * t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku 
 * sjednocených na totožné porovnatelné období – společné roky)
 */

CREATE OR REPLACE VIEW v_druha AS ( 
SELECT cpr.avg_price, cpc.name AS food_category, cpc.price_value AS food_price_amount,
	cpc.price_unit AS food_amount_unit, cr.name AS region_name, e.`year`, e.GDP, e.population,
	e.gini , e.taxes -- cpr.region_code (resp. region_name) IS NULL pre priemerne ceny potravinovych kategorii
FROM (
	SELECT YEAR(date_from) AS `year`, category_code, region_code, -- 342 riadkov 
		round((avg(value)), 2) AS avg_price
	FROM czechia_price cp 
	GROUP BY YEAR(date_from), category_code, region_code 
) AS cpr 
LEFT JOIN economies e 
	ON e.gini IS NOT NULL AND e.country = 'Czech Republic' AND cpr.`year` = e.`year`
LEFT JOIN czechia_region cr ON cpr.region_code = cr.code 
LEFT JOIN czechia_price_category cpc ON cpr.category_code = cpc.code
);

CREATE OR REPLACE TABLE t_zuzana_sevcikova_project_SQL_primary_final AS (
WITH prva AS (
	SELECT aa.payroll_year, cpb.name AS industry_branch, 
	aa.year_averaged_payroll_CZK -- , cpu.name AS unit
	FROM (
		SELECT payroll_year, industry_branch_code , avg(value) AS year_averaged_payroll_CZK
		FROM czechia_payroll cp 
		WHERE value_type_code = 5958 AND industry_branch_code IS NOT NULL 
		GROUP BY payroll_year, industry_branch_code 
	) AS aa
	LEFT JOIN czechia_payroll_industry_branch cpb ON cpb.code = aa.industry_branch_code	
 )
SELECT *
FROM v_druha d
LEFT JOIN prva p ON p.payroll_year = d.`year`
);

-- <- ================================================================================================= --