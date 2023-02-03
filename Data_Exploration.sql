SET sql_mode=""

/*SELECT * 
FROM covid_data_exploration.coviddeaths

SELECT * 
FROM covid_data_exploration.covidvaccinations */

-- selecting the data that we are going to use

/* UPDATE `covid_data_exploration`.`coviddeaths`
SET
`date` = <{date}>
WHERE <{where_expression}>;*/ -- to check&update the datatype of Date coulmn 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_data_exploration.coviddeaths
ORDER BY 1,2

-- looking at the ratio of affected cases vs death cases & showing the death posiblity if you get affected in your area 

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases),3)*100 AS death_percentage
FROM covid_data_exploration.coviddeaths
-- WHERE location like '%Bangladesh%'

-- looking at the ratio of affected cases vs popultion
 
SELECT location, date, total_cases, Population,ROUND((total_cases/Population),3)*100 AS affected_percentage
FROM covid_data_exploration.coviddeaths
-- WHERE location like '%Bangladesh%'

-- looking at the countries with highest infectection rate based on their population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/Population),3))*100 AS affected_percentage
FROM covid_data_exploration.coviddeaths
-- WHERE location like '%Bangladesh%'
GROUP BY location, Population
ORDER BY affected_percentage DESC

-- showing countries with highest death rate

ALTER TABLE `covid_data_exploration`.`coviddeaths` 
CHANGE COLUMN `total_deaths` `total_deaths` INT NULL -- changing data type while running agg.. function

SELECT Location, SUM(total_cases) AS Total_Cases, SUM(total_deaths) as TotalDeathCount,ROUND((SUM(total_deaths)/SUM(total_cases)*100),2) AS DeathPercentage
FROM covid_data_exploration.coviddeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC 

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, SUM(total_deaths) as TotalDeathCount
FROM covid_data_exploration.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount ASC

-- Showing continents with the highest death count/rates per population

SELECT continent, SUM(population) AS Total_Population, SUM(total_deaths) as TotalDeathCount
FROM covid_data_exploration.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

ALTER TABLE `covid_data_exploration`.`coviddeaths` 
CHANGE COLUMN `new_deaths` `new_deaths` INT NULL DEFAULT NULL ;

SELECT date,SUM(new_cases) as total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM covid_data_exploration.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 2,3

-- Global Death %

SELECT SUM(total_cases) as total_cases, SUM(total_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM covid_data_exploration.coviddeaths
WHERE continent IS NOT NULL

-- Looking at Total Population vs Vaccinations 

SELECT Deaths.location,MAX(Deaths.population),SUM(Vacs.new_vaccinations)
FROM covid_data_exploration.coviddeaths as Deaths
JOIN covid_data_exploration.covidvaccinations as Vacs ON 
Deaths.location = Vacs.location AND
Deaths.date = Vacs.date
GROUP BY Deaths.location
ORDER BY 2,3

SELECT Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations,
SUM(Vacs.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM covid_data_exploration.coviddeaths as Deaths
JOIN covid_data_exploration.covidvaccinations as Vacs ON 
Deaths.location = Vacs.location AND
Deaths.date = Vacs.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2,3


-- Creating CTE

WITH Population_VS_Vaccination(continent, location, date,population,new_vaccinations, RollingPeopleVaccinated)
AS 

(
SELECT Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations,
SUM(Vacs.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM covid_data_exploration.coviddeaths as Deaths
JOIN covid_data_exploration.covidvaccinations as Vacs ON 
Deaths.location = Vacs.location AND
Deaths.date = Vacs.date
WHERE Deaths.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Roll_Vacs_Percentage
FROM Population_VS_Vaccination



-- DROP TABLE IF EXISTS percentpopulationvaccinated
CREATE TABLE `covid_data_exploration`.`percentpopulationvaccinated` (
  `contitent` TEXT NULL,
  `location` TEXT NULL,
  `date` DATETIME NULL,
  `population` INT NULL,
  `new_vaccinations` INT NULL,
  `RollingPeopleVaccinated` INT NULL)

INSERT INTO percentpopulationvaccinated
SELECT Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations,
SUM(Vacs.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location,Deaths.date) AS RollingPeopleVaccinated
FROM covid_data_exploration.coviddeaths as Deaths
JOIN covid_data_exploration.covidvaccinations as Vacs ON 
Deaths.location = Vacs.location AND
Deaths.date = Vacs.date
-- WHERE Deaths.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM covid_data_exploration.percentpopulationvaccinated

-- created views for all the necessary numbers to store the data for later visualization







