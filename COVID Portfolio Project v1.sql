select *
from Portfolio_Project..covid_deaths
order by 3,4

--select *
--from Portfolio_Project..covid_vaccinations
--order by 3,4

select Location, date,total_cases,new_cases, total_deaths,population
from Portfolio_Project..covid_deaths
order by 1,2

select Location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percent
from Portfolio_Project..covid_deaths
where Location like '%states%'
order by 1,2


--alter table dbo.covid_deaths
--alter column total_cases float
--alter column total_deaths float

--alter table dbo.covid_deaths
--alter column population float
--Looking at Total Cases Vs Population

select Location, date,total_cases,population, (total_cases/population)*100 as Infected_percent
from Portfolio_Project..covid_deaths
--where Location like '%states%'
order by 1,2

--Looking at Countries with highest infection rate compared to population
select Location,population, max(total_cases) as Highest_Infection_Count, max(total_cases/population)*100 as Highest_Infected_percent
from Portfolio_Project..covid_deaths
group by location, population
order by Highest_Infected_percent desc
-- this one is incorrect because there are locations that have nothing,and continent that has nothing

-- Showing the countries with highest death count per population
select Location,population, max(total_deaths) as Highest_Death_Count, max(total_deaths/population)*100 as Highest_Death_percent
from Portfolio_Project..covid_deaths
where continent is not null
group by location, population
order by Highest_Death_Count desc

-- lets do things by continent
select location, max(total_deaths) as Highest_Deaths, max(total_deaths)/max(population)*100 as Highest_Death_percent
from Portfolio_Project..covid_deaths
where continent is null
group by location
order by Highest_Deaths desc

select continent, max(total_deaths) as Highest_Deaths
from Portfolio_Project..covid_deaths
where continent is not null
group by continent
order by Highest_Deaths desc

-- Global Numbers
select date, sum(new_cases),sum(new_deaths), sum(
from ..covid_deaths
where continent is not null
group by date
order by 1,2

select sum(new_cases),sum(new_deaths),sum(new_cases)/nullif(sum(new_deaths)*100,0)as Survival_rate
from..covid_deaths
where continent is not null
group by date

select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,sum(new_cases)/sum(new_deaths) as survival_rate,
case when new_deaths=0 then '0'
else sum(new_cases)/sum(new_deaths) end 
from ..covid_deaths

group by date,new_cases, new_deaths

select *
from..covid_deaths
order  by 4

select *
from covid_vaccinations

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from covid_deaths dea
join covid_vaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as continuous_vaccinated_amount
from covid_deaths dea
join covid_vaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3
--we now want to create another column that is a percentage of continuous vacinated over total amount of people
--we can use either CTE tables or temp tables

--using CTE 
with PopVsVac (continent,location,date,population, new_vacinations,continuous_vaccinated_amount)
as
(
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as continuous_vaccinated_amount
from covid_deaths dea
join covid_vaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
) 
select *, (continuous_vaccinated_amount/population)*100
from PopVsVac

--using temp tables
 create table #PercentPopulationVaccinated
 (
 continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 population numeric,
 New_Vaccinations numeric,
 continuous_vaccinated_amount numeric
 )
 insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as continuous_vaccinated_amount
from covid_deaths dea
join covid_vaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (continuous_vaccinated_amount/population)*100
from #PercentPopulationVaccinated

--if you want to use the temp table again, you have to add'drop table if exists "name of temp table" '

--creating view to store data for later

create view Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as continuous_vaccinated_amount
from covid_deaths dea
join covid_vaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
