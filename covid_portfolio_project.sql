SELECT location, str_to_date(date, '%m/%d/%Y'), total_cases, new_cases, total_deaths, population
FROM deaths
ORDER BY 1,2;

-- CASES VS DEATHS (%) / Likelihood of death
SELECT location, str_to_date(date, '%m/%d/%Y') date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percent
FROM deaths
ORDER BY 1,2;

-- Total cases vs. Population (%)
SELECT location, str_to_date(date, '%m/%d/%Y') date, total_cases, population, 
	(total_cases / population) * 100 AS case_percent
FROM deaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Countries w/ highest case rate vs. Population
SELECT location, MAX(total_cases) high_case_count, population, 
	MAX((total_cases / population)) * 100 AS high_case_percent
FROM deaths
GROUP BY 1,3
ORDER BY high_case_percent DESC;

-- Countries w/ highest death rate vs. Population 
	-- (removing continents in WHERE clause)
SELECT location, MAX(CAST(total_deaths as unsigned)) high_death_count
FROM deaths
WHERE continent != ''
GROUP BY 1
ORDER BY high_death_count DESC;

-- Global numbers
SELECT str_to_date(date, '%m/%d/%Y') date, SUM(new_cases) tot_cases, SUM(CAST(new_deaths as unsigned)) tot_deaths, 
	(SUM(CAST(new_deaths as unsigned)) / SUM(new_cases)) * 100 AS death_percent
FROM deaths
GROUP BY 1
ORDER BY 1,2;

-- Total population vs. Vaccination
With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vacc_count)
as
(
SELECT d.continent, d.location, str_to_date(d.date, '%m/%d/%Y') date, d.population,
	CAST(v.new_vaccinations as unsigned) new_vaccinations,
    SUM(CAST(v.new_vaccinations as unsigned)) OVER 
		(Partition By d.location order by d.location, d.date) rolling_vacc_count
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
    AND d.date = v.date
WHERE d.continent != '' 
)
SELECT *, (rolling_vacc_count/population) * 100 AS vaccination_rate
FROM pop_vs_vac;

-- Creating View for later use (visualizations)
CREATE View population_vaccination as
SELECT d.continent, d.location, str_to_date(d.date, '%m/%d/%Y') date, d.population,
	CAST(v.new_vaccinations as unsigned) new_vaccinations,
    SUM(CAST(v.new_vaccinations as unsigned)) OVER 
		(Partition By d.location order by d.location, d.date) rolling_vacc_count
FROM deaths d
JOIN vaccinations v
	ON d.location = v.location
    AND d.date = v.date
WHERE d.continent != '' 







