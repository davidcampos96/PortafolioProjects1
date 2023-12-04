select * 
from CovidDeahts

select * 
from CovidVaccinations

select location, date,total_cases,new_cases,total_deaths, population 
from CovidDeahts
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date,total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from CovidDeahts
where location like '%states%' 
order by 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date,total_cases,total_deaths, (CONVERT(float, total_cases) / CONVERT(float, population))*100 as CasesPercentage
from CovidDeahts
where location like 'Peru' and total_deaths is not null
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population 

select location,population,max(total_cases) as HighestInfectionCount, Max((CONVERT(float, total_cases) / CONVERT(float, population)))*100 as 
 PercentPopulationInfected
from CovidDeahts
--where location like 'Peru' and total_deaths is not null
group by location,population
order by PercentPopulationInfected desc
 

--Showing Countries with Highest Death Count Per Population

select location, MAX(cast(total_deaths AS float)) as TotalDeathCount
from CovidDeahts
--where location like 'Peru' and total_deaths is not null
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent

select continent, MAX(cast(total_deaths AS float)) as TotalDeathCount
from CovidDeahts
--where location like 'Peru' and total_deaths is not null
where continent is not null
group by continent
order by TotalDeathCount desc


--Let's break things down by continent
-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths AS float)) as TotalDeathCount
from CovidDeahts
--where location like 'Peru' and total_deaths is not null
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers

select  SUM(convert(float,new_cases)) as TotalCases, SUM(cast(new_deaths AS float)) as TotalDeaths
,SUM(cast(new_deaths AS float)) / SUM(convert(float,new_cases))*100 as DeathPercentage
from CovidDeahts
where continent is not null
--group by date
order by 1,2 


-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100 as %
from CovidDeahts dea
 join CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
with PopVsVac (continent,location, date, population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100 as %
from CovidDeahts dea
 join CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
select *, (RollingPeopleVaccinated / population)*100
from PopVsVac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100 as %
from CovidDeahts dea
 join CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100 as %
from CovidDeahts dea
 join CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select *
from PercentPopulationVaccinated