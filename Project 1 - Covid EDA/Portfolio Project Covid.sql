-- Covid 19 Data Exploration using Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4



-- Calculating Death Percentage
select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%' and  continent is not null
order by 1,2


-- total cases vs population
select Location, date, total_cases, population, (total_cases / population) * 100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


-- countries with highest infection rate compared to population
select location, population, max(total_cases) as highestInfectionCount, max((total_cases / population)) * 100 as infectionPercent
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location, population
order by infectionPercent desc


-- countries with highest death count per population
select location, max(cast(total_deaths as int)) as totalDeathCount	
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
order by totalDeathCount desc


-- breaking things by continent, beacuse the number where continent is null are more accurate
select location, max(cast(total_deaths as int)) as totalDeathCount	
from PortfolioProject..CovidDeaths
where continent is  null
GROUP BY location
order by totalDeathCount desc


-- continent with highest death count
select continent, max(cast(total_deaths as int)) as totalDeathCount	
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
order by totalDeathCount desc


-- global numbers by date
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))  / sum(new_cases) * 100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- global numbers till today
select  sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))  / sum(new_cases) * 100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations )) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select * , (RollingPeopleVaccinated/population) * 100
from PopVsVac



--- temp table
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


-- creating a view
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
