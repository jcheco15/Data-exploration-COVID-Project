SELECT *
FROM SQLportfolio ..COVIDdeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM SQLportfolio ..covidvaccs$
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM SQLportfolio ..COVIDdeaths
ORDER BY 1,2

-- Look at Total cases vs Total Deaths
--Shows what percentage of population got Covid

SELECT Location, date, total_cases, total_deaths,population, (total_cases/population)*100 as InfectionPercentage
FROM SQLportfolio ..COVIDdeaths   
Where location like '%states%' 
ORDER BY 1,2

--looking at countries with Highest infection rate compared to population

SELECT Location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as InfectionPercentage
FROM SQLportfolio ..COVIDdeaths   
--Where location like '%states%' 
GROUP BY location, population
ORDER BY InfectionPercentage desc

--showing countries with highest death count per population

--Seperate by continent
SELECT location,MAX(total_deaths) as Totaldeathcount
FROM SQLportfolio ..COVIDdeaths
where continent is NOT NULL
GROUP BY location
ORDER BY Totaldeathcount desc

-- global numbers

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacced
FROM SQLportfolio..COVIDdeaths dea
JOIN SQLportfolio..covidvaccs$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 