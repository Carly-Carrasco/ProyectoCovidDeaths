SELECT *
FROM project_one..covid_deaths
WHERE continent is  not null
ORDER BY 3,4

--SELECT *
--FROM project_one..covid_vaccinations
--ORDER BY 3,4

--Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project_one..covid_deaths
WHERE continent is  not null
order by 1,2

--to run the query modify the data type

ALTER TABLE covid_deaths ALTER COLUMN total_cases FLOAT
ALTER TABLE covid_deaths ALTER COLUMN total_deaths FLOAT

-- Looking at Total Cases v/s Total Deaths
--Shows likelihood of dying if you contract covid in my country and in United States


--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
--FROM project_one..covid_deaths
--Where location like '%chile%' 
--order by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM project_one..covid_deaths
Where location like '%states%'
and continent is  not null
order by 1,2


--Looking at Total Cases v/s Population
-- Show what percentage o population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected 
FROM project_one..covid_deaths
--Where location like '%states%' 
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPoulationInfected
FROM project_one..covid_deaths
--Where location like '%states%' 
GROUP BY location, population
ORDER BY PercentPoulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, Max(total_deaths) as TotalDeathCount
FROM project_one..covid_deaths
--Where location like '%states%' 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Let's break  things down by continent
-- Showing continents with the Highest Death Count pero Population


SELECT continent, Max(total_deaths) as TotalDeathCount
FROM project_one..covid_deaths
--Where location  like '%states%'
--and continent is not null
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SELECT location, Max(total_deaths) as TotalDeathCount
--FROM project_one..covid_deaths
--Where location like '%states%' 
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT total_cases , total_deaths, CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100  as DeathPercentage
FROM project_one..covid_deaths
WHERE continent is not null
	AND total_cases IS NOT NULL
	AND total_deaths IS NOT NULL
--ORDER BY  1,2

--Looking at Total Population v/s Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(CAST(vac.new_vaccinations as float )) OVER(partition BY dea.location ORDER BY dea.location, dea.DATE) as rollingPeopleVacinated
FROM project_one..covid_deaths dea
JOIN project_one..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
	
	
-- USE CTE

WITH PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(CAST(vac.new_vaccinations as float )) OVER(partition BY dea.location ORDER BY dea.location, dea.DATE) as RollingPeopleVaccinated
FROM project_one..covid_deaths dea
JOIN project_one..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(CAST(vac.new_vaccinations as float )) OVER(partition BY dea.location ORDER BY dea.location, dea.DATE) as RollingPeopleVaccinated
FROM project_one..covid_deaths dea
JOIN project_one..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for label visualizations

 Create View PercentPopulation as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(CAST(vac.new_vaccinations as float )) OVER(partition BY dea.location ORDER BY dea.location, dea.DATE) as RollingPeopleVaccinated
FROM project_one..covid_deaths dea
JOIN project_one..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3