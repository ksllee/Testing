SELECT
  location,
  population,
  MAX(total_cases) as HighestInfectionCount,
  MAX(total_cases/population) * 100 AS PercentPopulationInfected,
FROM
  `portfolioproject-365216.Covid19.CovidDeaths`
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at Total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
-- Looking at Total cases vs Population
-- Looking at countries with highest infection rate compared to population )30:50)
-- Showing countries with highest death count per population

SELECT
  location,
  MAX(total_deaths) as TotalDeathCounts
FROM
  `portfolioproject-365216.Covid19.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC;

-- Break things down by continent

SELECT
  continent,
  MAX(total_deaths) as TotalDeathCounts
FROM
  `portfolioproject-365216.Covid19.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC;

-- Global figures
SELECT
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths,
  (SUM(new_deaths)/ SUM(new_cases)) * 100 AS WorldDeathPercentage
FROM `portfolioproject-365216.Covid19.CovidDeaths`
WHERE continent is NOT NULL

-- Looking at total population vs Vaccinations
WITH cte AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location
    ORDER BY dea.location, dea.date
    ) AS rolling_vac_number
FROM `portfolioproject-365216.Covid19.CovidDeaths` dea
JOIN `portfolioproject-365216.Covid19.Vaccinations`vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)

SELECT *,
rolling_vac_number/population * 100 AS rolling_vac_percent
FROM cte

-- Create views to store data for later visualisations

CREATE VIEW portfolioproject-365216.Covid19.PercentPopulationVaccinated AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
      PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM `portfolioproject-365216.Covid19.CovidDeaths` dea
  JOIN `portfolioproject-365216.Covid19.Vaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
