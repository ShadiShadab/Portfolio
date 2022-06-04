--SELECT*
--FROM Portfolio . .['covid-deaths$']
--WHERE Continent isnot null
--ORDER BY 3, 4

--SELECT*
--FROM Portfolio . .['covid-vaccination$']
--ORDER BY 3, 4

--Select data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Posibility of dying because of Covid in Greece
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio . .['covid-deaths$']
WHERE location like '%Greece%' and continent is not null
ORDER BY 1, 2

-- Total Cases vs Population 

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM Portfolio . .['covid-deaths$']
WHERE location like '%Greece%' and continent is not null
ORDER BY 1, 2

-- Highest Case numbers compare to population

SELECT location,population, MAX(total_cases) AS HighestInfection, MAX(total_cases/population)*100 as InfectionPercentage
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
Group by population, location
ORDER BY InfectionPercentage desc

--Highest Death per Population

SELECT location, continent,  MAX(cast(Total_deaths as int)) as TotalDeaths
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
Group by location, continent
ORDER BY TotalDeaths desc

--Highest Death in continents per population

SELECT  continent,  MAX(cast(Total_deaths as int)) as TotalDeaths
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
Group by continent
ORDER BY TotalDeaths desc

--Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
Group by date
ORDER BY 1, 2

--Total Numbers

SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
ORDER BY 1, 2

--Total Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) 
 OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
 --, (RollingPeopleVaccinated /population)*100
FROM Portfolio . .['covid-deaths$'] Dea
JOIN  Portfolio . .['covid-vaccination$']  Vac
      ON Dea.location = Vac.location 
      AND Dea.date = Vac.date
WHERE Dea.continent is not null
ORDER BY 1, 2, 3

--USE CTE

With PopvsVac (continent, location, date,population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) 
 OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM Portfolio . .['covid-deaths$'] Dea
JOIN  Portfolio . .['covid-vaccination$']  Vac
      ON Dea.location = Vac.location 
      AND Dea.date = Vac.date
WHERE Dea.continent is not null
)
SELECT*, (RollingPeopleVaccinated /population)*100 as VaccinationPercentage
FROM PopvsVac

--TEMP Table

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) 
 OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM Portfolio . .['covid-deaths$'] Dea
JOIN  Portfolio . .['covid-vaccination$']  Vac
      ON Dea.location = Vac.location 
      AND Dea.date = Vac.date

SELECT*, (RollingPeopleVaccinated /population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated

--creating view for visualization

Create View PercentPopulationVaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) 
 OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM Portfolio . .['covid-deaths$'] Dea
JOIN  Portfolio . .['covid-vaccination$']  Vac
      ON Dea.location = Vac.location 
      AND Dea.date = Vac.date
WHERE Dea.continent is not null

Create View TotalNumbers as
SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null


Create View GlobalNumbers as
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
Group by date

Create View PosibilityOfDeathByCovidGreece as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio . .['covid-deaths$']
WHERE location like '%Greece%' and continent is not null

Create View HighestDeathsPerPopulation as
SELECT  continent,  MAX(cast(Total_deaths as int)) as TotalDeaths
FROM Portfolio . .['covid-deaths$']
WHERE continent is not null
Group by continent
