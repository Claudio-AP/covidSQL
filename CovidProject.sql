SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2

--look at total cases vs total deaths
--Likelihood of Death according to stats

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Kingdom%'
ORDER BY 1, 2

--Percentage of people that tested positive for covid

SELECT Location, date, total_cases, population, (total_cases/population)* 100 AS PosiitivePercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Kingdom%'
ORDER BY 1, 2

--Countries with highest infection rates

SELECT Location,  MAX(total_cases)AS highestInfectionRate , population, MAX((total_cases/population))* 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, population
ORDER BY InfectionPercentage desc

--countries with highest death count 

SELECT Location, MAX( CAST(total_deaths AS int)) AS DeathCount
FROM PortfolioProject..CovidDeaths$
WHERE Continent is not null
GROUP BY location
ORDER BY DeathCount desc


-- continents with highest death count

SELECT continent, MAX( CAST(total_deaths AS int)) AS DeathCount
FROM PortfolioProject..CovidDeaths$
WHERE Continent is not null
GROUP BY continent
ORDER BY DeathCount desc


--Global Data
SELECT  date, SUM(new_cases) AS totalCases, SUM(cast( new_deaths as int)) as totalDeaths, SUM(cast( new_deaths as int))/ SUM(new_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Vaccinatins vs Population 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

--Create temp table

DROP TABLE if exists #percentpopulationvaccinated

CREATE TABLE #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
INSERT INTO  #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT  *, (rollingpeoplevaccinated/population)*100
FROM  #percentpopulationvaccinated

--create view for visualisation

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
