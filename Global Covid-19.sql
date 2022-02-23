
select *
from Project1..CovidVaccinations$
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Project1..CovidDeaths$
order by 1,2

--looking at total_cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from Project1..CovidDeaths$
--where location like '%malaysia%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as 
percentpopulationinfected
from Project1..CovidDeaths$
--where location like '%malaysia%'
group by location, population
order by percentpopulationinfected desc

select location, population, date, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as 
percentpopulationinfected
from Project1..CovidDeaths$
--where location like '%malaysia%'
group by location, population, date
order by percentpopulationinfected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from Project1..CovidDeaths$
--where location like '%malaysia%'
where continent is not null
group by location
order by totaldeathcount desc

--by continent

select continent, max(cast(total_deaths as int)) as totaldeathcount
from Project1..CovidDeaths$
--where location like '%malaysia%'
where continent is not null
group by continent
order by totaldeathcount desc


--continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from Project1..CovidDeaths$
--where location like '%malaysia%'
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Project1..CovidDeaths$
--where location like '%malaysia%'
where continent is not null
--group by date
order by 1,2



--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as rollingpeoplevaccinated,
 (rollingpeoplevaccinated/population)*100
from Project1..CovidDeaths$ dea
join Project1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as rollingpeoplevaccinated
 --(rollingpeoplevaccinated/population)*100
from Project1..CovidDeaths$ dea
join Project1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac



--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as rollingpeoplevaccinated
 --(rollingpeoplevaccinated/population)*100
from Project1..CovidDeaths$ dea
join Project1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


-- view to store data for visualizations


create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as rollingpeoplevaccinated
 --(rollingpeoplevaccinated/population)*100
from Project1..CovidDeaths$ dea
join Project1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from percentpopulationvaccinated


--1.

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Project1..CovidDeaths$
--where location like '%malaysia%'
where continent is not null
--group by date
order by 1,2

--2

select location, sum(cast(new_deaths as int)) as totaldeathcount
from Project1..CovidDeaths$
--where location like '%malaysia%'
where continent is null
and location not in ('world', 'european union', 'international', 'upper middle income', 'high income'
, 'lower middle income', 'low income')
group by location
order by totaldeathcount desc

--3.

select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as 
percentpopulationinfected
from Project1..CovidDeaths$
--where location like '%malaysia%'
group by location, population
order by percentpopulationinfected desc

--4.

select location, population, date, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as 
percentpopulationinfected
from Project1..CovidDeaths$
--where location like '%malaysia%'
group by location, population, date
order by percentpopulationinfected desc