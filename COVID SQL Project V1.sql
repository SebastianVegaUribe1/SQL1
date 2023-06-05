select *
From [Portfolio projects].dbo.[CovidDeaths]
order by 3,4

select *
From [Portfolio projects].dbo.[CovidVaccinations]
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio projects].dbo.CovidDeaths
Order by 1,2

--Review Total Cases vs Total Deaths.
--Presents likelihood of dying if you contract Covid.

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio projects].dbo.CovidDeaths
where location like '%states%'
Order by 1,2

--Review Total cases vs Population.
--Present % of population got Covid.

select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from [Portfolio projects].dbo.CovidDeaths
--where location like '%states%'
Order by 1,2

--Review at countries with highest infection rate compared to population.
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from [Portfolio projects].dbo.CovidDeaths
--where location like '%states%'
group by location, population
Order by PercentagePopulationInfected desc

--Review at countries with highest infection rate compared to population as continent
select continent, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfectedbyContinent
from [Portfolio projects].dbo.CovidDeaths
group by continent, population
Order by PercentagePopulationInfectedbyContinent desc


--Showing Countries with highest death count per population1
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio projects].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
Order by TotalDeathCount desc

--Showing Countries with highest death count per continent
select continent, max(cast(total_deaths as int)) as TotalDeathCountContinent
from [Portfolio projects].dbo.CovidDeaths
where continent is not null
group by continent
Order by TotalDeathCountContinent desc

--Showing Countries with highest death count per continent
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio projects].dbo.CovidDeaths
--where location like '%states%'
where continent is null
group by location
Order by TotalDeathCount desc

--Showing Countries with highest death count per continent
select continent, max(cast(total_deaths as int)) as TotalDeathCountContinent
from [Portfolio projects].dbo.CovidDeaths
where continent is null
group by continent
Order by TotalDeathCountContinent desc


--Showing Countries with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio projects].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
Order by TotalDeathCount desc

--Continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio projects].dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
Order by TotalDeathCount desc


--Global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as Deat
from [Portfolio projects].dbo.CovidDeaths
where continent is not null
group by date
Order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio projects].dbo.CovidDeaths
where continent is not null
--group by date
Order by 1,2


--Review Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.Location)
From [Portfolio projects].dbo.CovidDeaths dea
join [Portfolio projects].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	Order by 2,3

	---option 2
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio projects].dbo.CovidDeaths dea
join [Portfolio projects].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	Order by 2,3


	with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio projects].dbo.CovidDeaths dea
join [Portfolio projects].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentange
From PopvsVac


--Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio projects].dbo.CovidDeaths dea
join [Portfolio projects].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentange
From #PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio projects].dbo.CovidDeaths dea
join [Portfolio projects].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--Order by 2,3


Select *
From PercentPopulationVaccinated