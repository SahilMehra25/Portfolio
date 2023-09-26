

--Data Exploration using SQL



select * 
from [port.project]..CovidDeaths
where continent is not  null
order by 3,4

--select * 
--from [port.project]..CovidVaccinations
--order by 3,4


select Location,date,total_cases,new_cases,total_deaths,population
from [port.project]..CovidDeaths
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [port.project]..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [port.project]..CovidDeaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max(total_cases/population)*100 as PercentPopulationInfected
From [port.project]..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc





--Percentage of Death

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "Death Percentage"
from [port.project]..CovidDeaths
where location='India'
order by 1,2


 --Total Cases vs Population
 
select Location,date,total_cases,Population,(total_cases/Population)*100 as "Infected People Percentage"
from [port.project]..CovidDeaths
----where location like '%India%'
order by 1,2


--Highest Infection Rate

Select Location,Population,Max(total_cases) as "highest Infection",Max((total_cases/population))*100 as "InfectedPeoplePercentage"
from [port.project]..CovidDeaths
where continent is not  null
group by Location,population
order by 4 desc

--Countries with highest death 
--as the type of total death is varchar we are facing a problem in the query to handle this we need to cast it as int

select location,Max(cast(total_deaths as int)) as"HighestDeath"
from [port.project]..CovidDeaths
where continent is not  null
Group by location
order by 2 desc 
 --by continent
select location,Max(cast(total_deaths as int)) as"HighestDeath"
from [port.project]..CovidDeaths
where continent is null
Group by location
order by 2 desc 

--Total Death Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [port.project]..CovidDeaths
where continent is not null 
order by 1,2

 --Deaths and New Cases as per Date

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [port.project]..CovidDeaths
where continent is not null 
Group By date
order by 1,2


--Total population vs Vaccination
--Rolling count
select D.continent,D.location,D.date,population,V.new_vaccinations,
sum(CONVERT(int,V.new_vaccinations)) over (Partition by D.location order by D.location,D.date) as Rollingcount
From [port.project]..CovidDeaths D
join [port.project]..CovidVaccinations V
  on D.location=V.location and D.date=V.date
  where V.continent is not null
order by 2,3



select a.*,(a.Rollingcount/a.population)*100 as "RollingCountPercentage"
from (select D.continent,D.location,D.date,population,V.new_vaccinations,
sum(CONVERT(int,V.new_vaccinations)) over (Partition by D.location order by D.location,D.date) as Rollingcount
From [port.project]..CovidDeaths D
join [port.project]..CovidVaccinations V
  on D.location=V.location and D.date=V.date
  where V.continent is not null)a


  --or we do the same using  CTE so in CTE we just make a new table from the previous query and then use it further for  more analysis

  With PopulationvsVacciantion (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
From [port.project]..CovidDeaths D
Join [port.project]..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopulationvsVacciantion


-- Using Temp Table to perform Calculation on Partition By in previous query Basically here we are creating a new table and then doing the same

DROP Table if exists #PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
From [port.project]..CovidDeaths D
Join [port.project]..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated



Create View Po1 as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
From [port.project]..CovidDeaths D
Join [port.project]..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 

Create View DeathContinent as
select location,Max(cast(total_deaths as int)) as"HighestDeath"
from [port.project]..CovidDeaths
where continent is null
Group by location


Create View DeathnewcasesPERDate as
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [port.project]..CovidDeaths
where continent is not null 
Group By date

