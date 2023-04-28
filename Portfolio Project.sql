Select *
FROM public."CovidDeaths"
Where continent is not null
order by 3,4



Select location, date, total_cases, new_cases, total_deaths, population
FROM public."CovidDeaths"
order by 1,2

-- Looking at the total cases vs. total deaths, looking at how many deaths they have per cases, in a percent, the ::numeric turns the column into a numeric value so I can get the # i am looking for. I added a where clause to specify what the rates where like in Canada
-- this number shows the likelihood of dying from Covid in your Country, in my case Canada
Select location, date, total_cases, total_deaths, (total_deaths::numeric/total_cases::numeric)*100::numeric as DeathPercentage
FROM public."CovidDeaths"
Where location like '%Canada%'
order by 1,2

-- Looking at total cases vs. population
-- shows the % of the population that got COVID
Select location, date, total_cases, population, (total_cases::numeric/population::numeric)*100::numeric as CasePercentage
FROM public."CovidDeaths"
Where location like '%Canada%'
order by 1,2

-- Looking at countries with the highest infection rate compared to population
Select location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases::numeric/population::numeric))*100::numeric as
	PercentPopulationInfected
FROM public."CovidDeaths"
--Where location like '%Canada%'
GROUP BY location, population
order by PercentPopulationInfected desc

-- Shows Countries with the highest death count per population
Select location, MAX(total_deaths) AS TotalDeathCount
FROM public."CovidDeaths"
--Where location like '%Canada%'
Where continent is not null
GROUP BY location
order by TotalDeathCount desc


-- Breaking things down by Continent 

Select continent, MAX(total_deaths) AS TotalDeathCount
FROM public."CovidDeaths"
--Where location like '%Canada%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per population
Select continent, MAX(total_deaths) AS TotalDeathCount
FROM public."CovidDeaths"
--Where location like '%Canada%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Global Numbers, new COVID cases by date

Select date, SUM(new_cases) as GlobalDailyCases, SUM(new_deaths) as GlobalDeaths
FROM public."CovidDeaths"
--Where location like '%Canada%' 
WHERE continent is not null
Group By date
order by 1,2

-- Global Death Percentage, error message, can't divide by zero
Select date, SUM(new_cases) as GlobalDailyCases, SUM(new_deaths) as GlobalDeaths,
	SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
FROM public."CovidDeaths"
--Where location like '%Canada%' 
WHERE continent is not null
Group By date
order by 1,2

-- Joined two tables, looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,
								 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From public."covidvac" as vac
JOIN public."CovidDeaths" as dea
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,
								 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From public."covidvac" as vac
JOIN public."CovidDeaths" as dea
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Creating a View to store data for later viz

Create View GlobalCovidCases as
Select date, SUM(new_cases) as GlobalDailyCases, SUM(new_deaths) as GlobalDeaths
FROM public."CovidDeaths"
--Where location like '%Canada%' 
WHERE continent is not null
Group By date
--order by 1,2




-- CREATING PercentPopulationVaccinated view
Create View PercentPopulationVaccinated as
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,
								 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From public."covidvac" as vac
JOIN public."CovidDeaths" as dea
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




Create View DeathCount as
Select continent, MAX(total_deaths) AS TotalDeathCount
FROM public."CovidDeaths"
--Where location like '%Canada%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc



Create View TotalCasesCanada as
Select location, date, total_cases, population, (total_cases::numeric/population::numeric)*100::numeric as CasePercentage
FROM public."CovidDeaths"
Where location like '%Canada%'
order by 1,2








