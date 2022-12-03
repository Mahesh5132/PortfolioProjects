select *
from PortfolioProject..covidDeaths
order by 3,4


select *
from PortfolioProject..covidVaccinations
order by 3,4



select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..covidDeaths
order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS


--SHOWS PERCENTAGE OF MORTALITY IF INFECTED, BY LOCATION BASIS


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 'DeathPercentage'
from PortfolioProject..covidDeaths
where location like 'india'
order by 1,2


--LOOKING AT TOTAL CASES VS POPULATION

--SHOW PERCENTAGE OF POPULATION INFECTED BY COVID


select location, date, total_cases, population, (total_cases/population)*100 'InfectionPercentage'
from PortfolioProject..covidDeaths
--where location like 'india'
order by 1,2

 
--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION


select location, max(total_cases) 'HIghestInfectionCount', population,max( (total_cases/population))*100 'PercentpopulationInfected'
from PortfolioProject..covidDeaths
--where location like 'india'
group by location, population
order by PercentpopulationInfected desc


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION


select location,MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like 'india'
where continent is not NULL
group by location
order by TotalDeathCount desc 


--LET'S BREAK DATA BY CONTINENT


select continent,MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like 'india'
where continent is not NULL --and location not like '%income%'
group by continent
order by TotalDeathCount desc 


--GLOBAL NUMBERS


select sum(new_cases) 'Total Cases', SUM(CAST(new_deaths as bigint))'Total Deaths', sum(cast(new_deaths as bigint))/sum(new_cases)*100 'DeathPercentage'
from PortfolioProject..covidDeaths
--where location like 'india'
where continent is not null
--Group by date
order by 1,2


-- Lookiung at Total Population Vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 'RollingPeopleVaccinated'
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like 'albania'
order by 2,3


--USE CTE


with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 'RollingPeopleVaccinated'
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like 'albania'
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 'RollingVaccPercent'
from PopvsVac


--TEMP TABLE


Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric	
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) 'RollingPeopleVaccinated'
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null --and dea.location like 'albania'
--order by 2,3
--where dea.location like'India'
select *, (RollingPeopleVaccinated/population)*100 'RollingVaccPercent'
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION


Drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 'RollingPeopleVaccinated'
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like 'india'
--order by 2,3

select *
from PercentPopulationVaccinated