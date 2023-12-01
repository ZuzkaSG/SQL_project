/*
 * 2: Kolik je možné si koupit litrů mléka a kilogramů chleba 
 * za první a poslední srovnatelné období v dostupných datech cen a mezd?
 * 
 * 114201	Mléko polotučné pasterované	1.0	l
 * 111301	Chléb konzumní kmínový	1.0	kg
 * hrubá mzda * (1-dan) = cista mzda zavisi od regionu nie od profesie (year and republic averaded payroll)
 * cpr.region_code (resp. region_name) IS NULL pre priemerne ceny potravinovych kategorii
 */

CREATE OR REPLACE VIEW v_zs_task2 AS (
SELECT avg_price , food_category ,region_name, industry_branch, -- 266 riadkov s DISTINCT aj bez
 	round((year_averaged_payroll_CZK * (1 - (taxes/100))), 1) AS net_wages,
 	round(((year_averaged_payroll_CZK * (1 - (taxes/100))) / avg_price), 1) AS amount_to_buy 
FROM t_zuzana_sevcikova_project_sql_primary_final tzspspf 
WHERE food_category LIKE 'Ml_ko%' and region_name IS NOT NULL AND payroll_year = 2006 	-- sem: mleko / chleb a 2006 / 2018
);


SELECT region_name, industry_branch, net_wages, amount_to_buy
FROM v_zs_task2
WHERE (net_wages, amount_to_buy) IN (
    SELECT MIN(net_wages), MIN(amount_to_buy)
    FROM v_zs_task2
    UNION
    SELECT MAX(net_wages), MAX(amount_to_buy)
    FROM v_zs_task2
); 
-- toto trva dlho: 8m 52s





