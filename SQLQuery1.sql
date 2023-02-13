SELECT *
FROM Porftolioproject..[covid_deaths$]
WHERE continent IS NOT NULL
ORDER by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Porftolioproject..covid_deaths$
ORDER BY 1,2--

--Looking at total cases vs. total deaths, likelihood of death in total cases.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM Porftolioproject..covid_deaths$
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2

--Looking at Countries with Highest infection rate comparing to Population
SELECT 
location, 
population,
MAX(total_cases) AS Highest_infection_rate,
MAX((total_cases/population))*100 AS death_percentage
FROM Porftolioproject..covid_deaths$
GROUP BY location, population
ORDER BY 1,2 
--Showing Countries with highest death count per population
SELECT Location, MAX(cast(Total_deaths AS int)) as TotalDeathCount
FROM Porftolioproject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc
--Global numbers
SELECT 
SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_percentage 
FROM Porftolioproject..covid_deaths$
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2 DESC;
--Joining two tables
With PopvsVac (Continent, Location, Date, Population, new_vaccinations,rolling_people_percentage)
AS
(
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_percentage
FROM Porftolioproject..covid_deaths$ dea
JOIN Porftolioproject..Vaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--ORDER BY 1,2
)
SELECT *, (rolling_people_percentage/Population)*100 
From PopvsVac


--Creating CTE 
Drop table if exists Percent_Population_Vaccinated
Create table Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
rolling_people_percentage numeric
)

INSERT INTO Percent_Population_Vaccinated

SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_percentage
FROM Porftolioproject..covid_deaths$ dea
JOIN Porftolioproject..Vaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (rolling_people_percentage/Population)*100 
From Percent_Population_Vaccinated

--TEMP table
USE Porftolioproject
GO 
Create View rolling_people_percentage AS 
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_percentage
FROM Porftolioproject..covid_deaths$ dea
JOIN Porftolioproject..Vaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL