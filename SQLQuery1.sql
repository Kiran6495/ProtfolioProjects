SELECT*
FROM ProtfolioProject..covid_deaths
WHERE continent is not null
ORDER by 3,4

SELECT*
FROM ProtfolioProject..covid_vacination
ORDER by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProtfolioProject..covid_deaths
WHERE continent is not null
ORDER by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as death_percentage
FROM ProtfolioProject..covid_deaths
WHERE location like '%India%'
WHERE continent is not null
ORDER by 1, 2

SELECT location, date, total_cases, population, (total_cases/population)*100 as total_case_percentage
FROM ProtfolioProject..covid_deaths
WHERE location like '%India%'
WHERE continent is not null
ORDER by 1, 2

SELECT location, population, MAX(total_cases) as highest_cases, Max((total_cases/population))*100 as total_case_percentage
FROM ProtfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER by total_case_percentage DESC

SELECT location, MAX(cast(total_deaths as int)) as highest_deaths
FROM ProtfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER by highest_deaths DESC

SELECT continent, MAX(cast(total_deaths as int)) as highest_deaths
FROM ProtfolioProject..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER by highest_deaths DESC

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as death_percentage
FROM ProtfolioProject..covid_deaths
--WHERE location like '%India%'
WHERE continent is not null
ORDER by 1, 2

SELECT date, SUM(new_cases)--, total_deaths, (total_deaths/total_cases*100) as death_percentage
FROM ProtfolioProject..covid_deaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY date
ORDER by 1, 2

SELECT date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM ProtfolioProject..covid_deaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY date
ORDER by 1, 2

SELECT *
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and cast(dea.date as int) = cast(vac.date as int)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and cast(dea.date as int) = cast(vac.date as int)
WHERE dea.continent is not null
ORDER by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location ORDER BY dea.location, dea.date)
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and dea.date = vac.date 
WHERE dea.continent is not null
ORDER by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as total_vaccinated
, (total_vaccinated/popolation)*100
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and cast(dea.date as int) = cast(vac.date as int)
WHERE dea.continent is not null
ORDER by 2,3

WITH popvsvac (continent, location, date, population,new_vaccination,total_vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as total_vaccinated
--, (total_vaccinated/popolation)*100
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and cast(dea.date as int) = cast(vac.date as int)
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT *, (total_vaccinated/population)*100
FROM popvsvac

DROP TABLE IF EXISTS #Vaccinated
CREATE TABLE #Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinated numeric
)
INSERT INTO #Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as total_vaccinated
--, (total_vaccinated/popolation)*100
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER by 2,3

SELECT *, (total_vaccinated/population)*100
FROM #Vaccinated

CREATE VIEW Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
as total_vaccinated
--, (total_vaccinated/popolation)*100
FROM ProtfolioProject..covid_deaths dea
JOIN ProtfolioProject..covid_vacination vac
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3