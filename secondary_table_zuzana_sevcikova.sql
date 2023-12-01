/*
 * Secondary table
 * t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).
 * 
 * - tab. countries je podla dat len pre rok 2018 stlpec median_age_2018, nejde pouzit stlpce s udajmi meniacimi sa v case,
 * neobsahuje data pozitelne pre projektove ulohy
 * - tab. economies obs. data pre CR, ktore su vybrate do primary table, 
 * - data z tab. economies pre ostatne staty nie su pouzitelne v projektovych ulohach, lebo neobsahuju info o cenach potravin
 * a mzdach pouzitelne na porovnanie
 * - pod evropskymi staty neuvazuji o extrateritorialnich a zamorskych statech a koloniich evropsk7ch statu
 */



CREATE OR REPLACE TABLE t_zuzana_sevcikova_project_sql_secondary_final AS (
SELECT e.country , e.`year` , e.GDP , e.population , e.gini , e.taxes ,
	c.abbreviation , c.capital_city , c.continent , c.currency_code
FROM economies e
LEFT JOIN countries c ON e.country = c.country AND c.continent = 'Europe'	
WHERE e.gini IS NOT NULL AND e.`year` >= 2006 AND e.`year` <= 2018 
	AND c.continent IS NOT NULL 
);




