SELECT *
from Portfolio_Project..CovidDeaths
where continent is NOT NULL
ORDER by 3,4


-- SELECT *
-- from Portfolio_Project..CovidVaccinations
-- ORDER by 3,4

-- Select Data that we are going to be using

SELECT [location],[date],new_cases,total_deaths,population
from Portfolio_Project..CovidDeaths
where continent is NOT NULL
order BY 1,2

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country
SELECT [location],[date],total_cases,total_deaths
,(total_cases/total_deaths * 100) as Death_Percentage
from Portfolio_Project..CovidDeaths
WHERE [location] like 'SOUTH AFRICA%'
and  continent is NOT NULL
ORDER BY 1,2 

--Looking at the Total Cases Vs Population
--Shows what percentage of population got Covid

SELECT [location],[date],total_cases,population,(total_cases/population * 100) as Population_percentage
from Portfolio_Project..CovidDeaths
WHERE [location] like 'SOUTH AFRICA%'
ORDER BY 1,2 

--Looking at Countries with Highest Infection Rate comapared to Population

SELECT [location],population,MAX(total_cases) as Highest_Infection_Count
,MAX((total_cases/population * 100)) as percentOfPopulationInfected
from Portfolio_Project..CovidDeaths
GROUP by [location], population
ORDER BY percentOfPopulationInfected DESC

--Showing Countries with  Highest Death Count per Population

SELECT [location],MAX(total_deaths) as Total_Death_Count
from Portfolio_Project..CovidDeaths
where continent is NOT NULL
GROUP BY [location]
ORDER by Total_Death_Count DESC

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents with Highest Death Count per Population

SELECT [continent],MAX(total_deaths) as Total_Death_Count
from Portfolio_Project..CovidDeaths
where continent is NOT NULL
GROUP BY [continent]
ORDER by Total_Death_Count DESC

--GLOBAL NUMBERS

 SELECT  SUM(new_cases)as total_cases
 ,SUM(CAST(new_deaths as int)) as total_death
 ,SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as Death_Percetage
 FROM Portfolio_Project..CovidDeaths
 WHERE continent is NOT NULL
 --GROUP by [date]
 ORDER by 1,2


--Looking at Total Population vs vaccinations

SELECT dea.continent,
 dea.[location],
 dea.[date],
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
 --,(Rolling_People_Vaccinated/population) * 100
 FROM Portfolio_Project..CovidDeaths dea
 JOIN Portfolio_Project..CovidVaccinations vac 
 on dea.[location] = vac.[location]
 and dea.date = vac.date
 where dea.continent is not NULL
 ORDER by 2,3


 --USE CTE 

WITH PopvsVac(continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
AS (
 SELECT dea.continent,
 dea.[location],
 dea.[date],
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
 --,(Rolling_People_Vaccinated/population) * 100
 FROM Portfolio_Project..CovidDeaths dea
 JOIN Portfolio_Project..CovidVaccinations vac 
 on dea.[location] = vac.[location]
 and dea.date = vac.date
 where dea.continent is not NULL
 --ORDER by 2,3
)
 SELECT * ,(Rolling_People_Vaccinated/population ) * 100 
 FROM PopvsVac


 --TEMP TABLE

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    location NVARCHAR (255),
    DATE DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    Rolling_People_Vaccinated NUMERIC
)

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,
 dea.[location],
 dea.[date],
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
 --,(Rolling_People_Vaccinated/population) * 100
 FROM Portfolio_Project..CovidDeaths dea
 JOIN Portfolio_Project..CovidVaccinations vac 
 on dea.[location] = vac.[location]
 and dea.date = vac.date
 --where dea.continent is not NULL
 ORDER by 2,3

 SELECT * ,(Rolling_People_Vaccinated/population ) * 100 
 FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE  DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,
 dea.[location],
 dea.[date],
 dea.population,
 vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) 
 OVER (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
 --,(Rolling_People_Vaccinated/population) * 100
 FROM Portfolio_Project..CovidDeaths dea
 JOIN Portfolio_Project..CovidVaccinations vac 
 on dea.[location] = vac.[location]
 and dea.date = vac.date
 where dea.continent is not NULL
-- ORDER by 2,3

Select *
FROM PercentPopulationVaccinated