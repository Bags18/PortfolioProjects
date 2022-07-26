SELECT * 
FROM [Portfolio Project]..CovidDeaths
Order by 3,4

--SELECT * 
--FROM [Portfolio Project]..CovidVaccinations$
--Order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as Infection_rates
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at Countries with highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
Group by Location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Hightest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
Group by Location
ORDER BY Total_Death_Count desc

--Break Down by Continent
--Showing contintents with the highest death count

SELECT location,MAX(cast(total_deaths as int)) as Total_Death_Count
FROM [Portfolio Project]..CovidDeaths
WHERE continent is null
Group by location
ORDER BY Total_Death_Count desc

--Global Numbers
--By Date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
Group by date
ORDER BY 1,2

--Total death percentage in world

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Vaccinations

SELECT *
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT * 
FROM PercentPopulationVaccinated








