--Extracted data from excel files to SQL
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..coviddeaths$ 
order by 1,2

--------------------------------------------------------------------------
--Chances of dying if contracted covid in  india/
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths$ 
where location like '%india%' 
order by 1,2

---------------------------------------------------------------------------
--Percentage of population that got covid 
select location,max(total_cases) as highestinfected,max((total_cases/population))*100 as population_infected
from portfolioproject..coviddeaths$ 
group by location
order by 1;

----------------------------------------------------------------------------
--Death count in various country
select location,max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths$ 
where continent is not null
group by location
order by 2 desc;

---------------------------------------------------------------------------
--Continents with highest number of deaths
select continent,max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths$ 
where continent is not null
group by continent
order by 2 desc;

-----------------------------------------------------
--Cases count per day since the very first case was reported
select date,sum(new_cases) as total_Cases,sum(cast(new_deaths as int)) as total_deaths
from portfolioproject..coviddeaths$ 
where continent is not null 
group by date
having sum(new_cases)>0
order by 1 ;

------------------------------------------------------------------------------------
--Join of 2 tables
select * from portfolioproject..coviddeaths$ cd join 
portfolioproject..covidVaccines$ cv
on cd.location=cv.location and cd.date=cv.date

----------------------------------------------------
--Perctange of population of a location getting vaccincated on daily basis
with newtab (continent,location,date,population,new_vaccinations,rolling_vaccinartions)
as (select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over(partition by cv.location order by cv.location ,cv.date ) rolling_vaccinartions
from portfolioproject..coviddeaths$ cd join 
portfolioproject..covidVaccines$ cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null)
select *,(rolling_vaccinartions/population)*100 from newtab
order by 2,3

-------------------------------------------------
--Creating View 
create view rollingpopvac as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over(partition by cv.location order by cv.location ,cv.date ) rolling_vaccinartions
from portfolioproject..coviddeaths$ cd join 
portfolioproject..covidVaccines$ cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
)

------------------------------------------------------
--Use View
select * from rollingpopvac


