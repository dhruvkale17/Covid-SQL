--Total cases vs Total Deaths
--Shows probability of death in India in Covid patients
SELECT location, date, total_cases, total_deaths, (CONVERT(FLOAT,total_deaths)/CONVERT(FLOAT,total_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE location ='India' 
ORDER BY 2

--Total cases vs Population
--Shows what percentage of population in India contracted Covid
SELECT location, date, total_cases, population, (CONVERT(numeric(16,8), (total_cases/population)*100)) as PositivePercentage
FROM CovidDeaths
WHERE location ='India' 
ORDER BY 2

--Countries with Highest Infection Rate by Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as MaxPositivePercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY MaxPositivePercentage DESC

--Countries with Highest Death Count
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with Highest Death Count
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE location in ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global new cases, new deaths, DeathPercentage by date
SELECT date, SUM(new_cases) as NewCases, SUM(new_deaths) as NewDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

--Total Population vs Vaccinations by date
--CTE
With POPvsVAX (Continent, Location, Date, Population, NewVaccinations, TotalVaccinations)
as
(SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, 
	SUM(CAST(vaccs.new_vaccinations as bigint)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
FROM CovidDeaths deaths
JOIN CovidVaccinations vaccs
	ON deaths.date = vaccs.date
	AND deaths.location = vaccs.location
WHERE deaths.continent is not null
)
SELECT *, (TotalVaccinations/population)*100 as PercentagePopulationVaccinated
FROM POPvsVAX

--Creating View to store data for Visualizations
Create View PopulationVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, 
	SUM(CAST(vaccs.new_vaccinations as bigint)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as TotalVaccinations
FROM CovidDeaths deaths
JOIN CovidVaccinations vaccs
	ON deaths.date = vaccs.date
	AND deaths.location = vaccs.location
WHERE deaths.continent is not null


