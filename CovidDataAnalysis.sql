--SELECT *
--FROM covidProject..covidDeaths
--ORDER BY 3,4

--SELECT *
--FROM covidProject..covidVaccinations
--ORDER BY 3,4

--Select the data that we are going to be using
select location, date, total_cases, new_cases,total_deaths, population
from covidProject..covidDeaths
order by 1,2

--Looking at total cases vs totl deaths
--Linkelihood of dying if you contract covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from covidProject..covidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
select location, date, total_cases,population, (total_cases/population)*100 as PrecentOfPopulationGotCovid
from covidProject..covidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Looking at countries with hightest infection rate  compared to population
select location, max(total_cases) as HighestInfectionCount ,population, max(total_cases/population)*100 as PrecentOfPopulationGotCovid
from covidProject..covidDeaths
where continent is not null
group by location, population
order by PrecentOfPopulationGotCovid desc

--Showing countries with highest death counts per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covidProject..covidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent
--showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from covidProject..covidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100
from covidProject..covidDeaths
--where location like '%states%' 
where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
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
From covidProject..CovidDeaths dea
Join covidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 