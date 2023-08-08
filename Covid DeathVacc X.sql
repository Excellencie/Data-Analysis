SELECT * 
FROM portfoliodb..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM portfoliodb..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select required columns

SELECT location, date, population, total_cases, total_deaths, new_cases
FROM portfoliodb..CovidDeaths
ORDER BY 1,2

-- Calculate percentage death rate; shows the likelihood of dying from covid if you contracted it in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentdeath
FROM portfoliodb..CovidDeaths
WHERE location = 'Nigeria'
  AND continent IS NOT NULL
ORDER BY 1,2

-- Calculate population us total_cases; shows percentage of the population has gotten covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 as percentpop
FROM portfoliodb..CovidDeaths
WHERE location = 'Nigeria'
	AND  continent IS NOT NULL
ORDER BY 1,2

-- See Countries with the highest infection rates

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopInfected
FROM portfoliodb..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- See countries with the highest death counts

SELECT location, MAX(CAST(total_deaths AS INT)) as TotaltDeathCount 
FROM portfoliodb..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Break things down by continent

SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathsCount
FROM portfoliodb..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS  NULL
GROUP BY location
ORDER BY 2 DESC 

-- Global Numbers
SELECT date, SUM(new_cases) AS TotalCasesCount, SUM(CAST (new_deaths AS int)) as TotalDeathCount, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100  AS  GlobalDeathPercnet
FROM portfoliodb..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2,3 ASC

-- Looking at total population vs total vaccinations
SELECT deaths.continent, 
deaths.location, 
deaths.population, 
deaths.date, 
vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS int)) OVER( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingCount
--,vacc.total_vaccinations
FROM PortfolioDB..coviddeaths as deaths
JOIN PortfolioDB..CovidVaccinations as vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
	WHERE deaths.continent IS NOT NULL
	ORDER BY 2, 3

-- For better visualizations use CTE/Temp Table/View

-- Use CTE 
WITH PopvsVac  
AS (
SELECT deaths.continent, 
deaths.location, 
deaths.population, 
deaths.date, 
vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS int)) OVER( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingCountVac
--,vacc.total_vaccinations
FROM PortfolioDB..coviddeaths as deaths
JOIN PortfolioDB..CovidVaccinations as vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
	WHERE deaths.continent IS NOT NULL
	--ORDER BY 2, 3
	)

SELECT *, ROUND((RollingCountVac/population)*100,3) AS PercentageVaccinated
FROM PopvsVac
ORDER BY 1,2

-- Use Views

CREATE VIEW PopVacc AS
SELECT deaths.continent, 
deaths.location, 
deaths.population, 
deaths.date, 
vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS int)) OVER( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingCountVac
--,vacc.total_vaccinations
FROM PortfolioDB..coviddeaths as deaths
JOIN PortfolioDB..CovidVaccinations as vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
-- ORDER BY 2, 3

-- check view
SELECT *, ROUND((RollingCountVac/population)*100,3) AS PercentagePopVaccinated
FROM PopVacc

-- Use a temp table

DROP TABLE IF EXISTS #PercentagePopVacc
CREATE TABLE #PercentagePopVacc
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime, 
new_vaccinations numeric,
RollingCountVac numeric
)

INSERT INTO #PercentagePopVacc
SELECT deaths.continent, 
deaths.location, 
deaths.population, 
deaths.date, 
vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS int)) 
	OVER( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingCountVac
--,vacc.total_vaccinations
FROM PortfolioDB..coviddeaths as deaths
JOIN PortfolioDB..CovidVaccinations as vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL

SELECT *, CAST(ROUND((RollingCountVac/population)*100,3) AS DECIMAL(10,2)) AS PercentagePopVaccinated
FROM #PercentagePopVacc
