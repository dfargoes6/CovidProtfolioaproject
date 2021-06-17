Select *
From ProtfoilioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From ProtfoilioProject..CovidVaccinations
--order by 3,4
--Select Data that we are selecting

Select location,date,total_cases,new_cases,total_cases,population
From ProtfoilioProject..CovidDeaths
where continent is not null
order by 1,2


--Total Cases vs Total Deaths
--likelihood of dying if you get covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From ProtfoilioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2

--Looking at Total cases vs population
--Shows what percentage got covid
Select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
From ProtfoilioProject..CovidDeaths
where location like '%india%' and continent is not null
order by 1,2

--Looking at countries with highest infalction rate compared to population
Select location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as CovidPercentage
From ProtfoilioProject..CovidDeaths
where continent is not null
Group by population,location
order by CovidPercentage desc

--Countries with highest death count percentage
Select location,MAX(cast(total_deaths as int)) as HighestDeathCount
From ProtfoilioProject..CovidDeaths
where continent is not null
Group by location
order by HighestDeathCount desc

--Contients with highest death count percentage
Select continent,MAX(cast(total_deaths as int)) as HighestDeathCount
From ProtfoilioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount desc

--Showing continents with highest death count per population
Select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as float)) as TotalDeaths,SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From ProtfoilioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) 
over (Partition  by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfoilioProject..CovidDeaths dea
join ProtfoilioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3

With PopVSVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) 
over (Partition  by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfoilioProject..CovidDeaths dea
join ProtfoilioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PopVsVac

--Using temp table
--DROP Table if exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePeopleVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) 
over (Partition  by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfoilioProject..CovidDeaths dea
join ProtfoilioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

Select * ,(RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from #PercentagePeopleVaccinated

--creating views for Vizualization
Create view DeathPercentage as
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From ProtfoilioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--order by 1,2
select * from DeathPercentage

create view CovidPercentage as
Select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
From ProtfoilioProject..CovidDeaths
--where location like '%india%' and
where continent is not null
--order by 1,2
select * from CovidPercentage

create view HighestInfectionCount as
Select location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as CovidPercentage
From ProtfoilioProject..CovidDeaths
where continent is not null
Group by population,location
--order by CovidPercentage desc
select * from HighestInfectionCount

create view HighestDeathCountCountries as
Select location,MAX(cast(total_deaths as int)) as HighestDeathCount
From ProtfoilioProject..CovidDeaths
where continent is not null
Group by location
--order by HighestDeathCount desc
select * from HighestDeathCountCountries order by 2 desc

create view HighestDeathCountContinents as
Select continent,MAX(cast(total_deaths as int)) as HighestDeathCount
From ProtfoilioProject..CovidDeaths
where continent is not null
Group by continent
--order by HighestDeathCount desc
select * from HighestDeathCountContinents

create view WorldDeathPercentage as
Select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as float)) as TotalDeaths,SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From ProtfoilioProject..CovidDeaths
where continent is not null
--group by date
--order by 1,2
select * from WorldDeathPercentage

Create view PercentagePeopleVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) 
over (Partition  by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfoilioProject..CovidDeaths dea
join ProtfoilioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

create view RollingVaccination as
With PopVSVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) 
over (Partition  by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProtfoilioProject..CovidDeaths dea
join ProtfoilioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PopVsVac
select * from RollingVaccination