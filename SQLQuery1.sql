-- Revisamos el dataset
select * 
from DB1..CovidDeaths$
where continent is not null
order by 3,4

-- Observamos los casos totales, los contagios totales y la probabilidad de muerte por covid en EEUU

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from DB1..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Observamos casos totales, población y el porcentage de casos frente al total de población en EEUU

select location, date, total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
from DB1..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Observamos los paises con mayores ratios de infección en relación a su población

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from DB1..CovidDeaths$
where continent is not null
group by location, population
order by PercentagePopulationInfected desc


-- Observamos los países donde más población ha fallecido

select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from DB1..CovidDeaths$
where continent is not null
group by location, population
order by TotalDeathCount desc

-- Desglosando los datos por continente

select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from DB1..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

-- Desglosando los datos por continente

select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from DB1..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Mostramos los continentes con mayores tasas de fallecidos según su población

select continent, max (cast(total_deaths as int)) as TotaldeathCount
from DB1..CovidDeaths$
where continent is not null
group by continent
order by TotaldeathCount desc

-- Datos globales

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from DB1..CovidDeaths$
where continent is not null
order by 1,2

-- Desglosando datos globales

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from DB1..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Revisando la población mundial vs la vacunacion

with PopvsVac (continent, location,date,population, new_vaccinations, rolling_people_vaccinations)
as (
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations --, (rolling_people_vaccinations/population)*100 as percentage_rolling
from DB1..CovidDeaths$ dea
join DB1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
select *, (rolling_people_vaccinations/population)*100 as rolling_percentage
from PopvsVac

-- Usando una tabla temporal 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations --, (rolling_people_vaccinations/population)*100 as percentage_rolling
from DB1..CovidDeaths$ dea
join DB1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

select *--, (rolling_people_vaccinations/population)*100 as rolling_percentage
from #PercentPopulationVaccinated

-- Creamos una vista para almacenar los datos para mostrar una visualización posteriormente

create view PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations --, (rolling_people_vaccinations/population)*100 as percentage_rolling
from DB1..CovidDeaths$ dea
join DB1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

select *
from PercentPopulationVaccinated