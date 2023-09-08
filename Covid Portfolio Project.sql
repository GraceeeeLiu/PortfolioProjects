use PortfolioProject;
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like "%Taiwan%"
order by 1,2;


-- look at total cases vs population
-- show what percentage of population got covid
select location, date, Population, total_cases, (total_cases/population)*100 as PercentPoPulationInfected
from coviddeaths
-- where location like "%Taiwan%"
order by 1,2;



-- looking at country with highest infection rate compared to population
select location, Population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPoPulationInfected
from coviddeaths
-- where location like "%Taiwan%"
group by location, population
order by PercentPoPulationInfected desc;

-- showing country with highest death count per population
select location, MAX(Total_deaths) as TotalDeathCount
from coviddeaths
-- where location like "%Taiwan%"
where continent is not null
group by location
order by TotalDeathCount desc;


-- break things down by continent
-- showing continents with the highest death count per population
select continent, MAX(Total_deaths) as TotalDeathCount
from coviddeaths
-- where location like "%Taiwan%"
where continent is not null
group by continent
order by TotalDeathCount desc;

-- global numbers
select  sum(new_cases) as total_cases, sum(new_deaths) as total_death, sum(new_deaths)/sum(new_cases) *100 as DeathPercentage 
from coviddeaths
-- where location like "%Taiwan%"
where continent is not null
-- group by date
order by 1,2;


-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from coviddeaths dea
left join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- Use CTE
with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from coviddeaths dea
left join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac;



-- temp table
drop table if exists PercentPopulaationVaccinated;
create table PercentPopulaationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
);
insert into PercentPopulaationVaccinated
select 
	dea.continent,
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
		as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from coviddeaths dea
left join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from PercentPopulaationVaccinated;


-- creating view to store data for later visualiations
create view percentpopulationvaccinated as 
select 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
		as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from coviddeaths dea
left join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3;

select * from percentpopulationvaccinated
