/*
 * 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

 Jmeno: Zuzana Ševčíková
uzivatelske jmeno na Discordu: Zuzana Š.
uzivatelske jmeno na GitHubu: ZuzkaSG
 */


WITH p2018 AS (
	SELECT DISTINCT tzsp.payroll_year, tzsp.industry_branch, 
		tzsp.year_averaged_payroll_CZK AS payroll_2018
	FROM t_zuzana_sevcikova_project_sql_primary_final tzsp
	WHERE payroll_year = 2018
),
p2006 AS (
	SELECT DISTINCT tzsp.payroll_year, tzsp.industry_branch, 
		tzsp.year_averaged_payroll_CZK AS payroll_2006
	FROM t_zuzana_sevcikova_project_sql_primary_final tzsp
	WHERE payroll_year = 2006
)
SELECT DISTINCT tzsp.payroll_year, tzsp.industry_branch, 
	CASE WHEN (p2018.payroll_2018 - p2006.payroll_2006)>= (tzsp.year_averaged_payroll_CZK - p2006.payroll_2006) 
	THEN round(((tzsp.year_averaged_payroll_CZK - p2006.payroll_2006) 
	/ (p2018.payroll_2018 - p2006.payroll_2006)), 3) ELSE 'decreases'
	END AS relative_payroll_increase
FROM t_zuzana_sevcikova_project_sql_primary_final tzsp
LEFT JOIN p2018 
	ON p2018.industry_branch = tzsp.industry_branch	
LEFT JOIN p2006 
	ON p2006.industry_branch = tzsp.industry_branch
GROUP BY tzsp.industry_branch, tzsp.payroll_year 
;






