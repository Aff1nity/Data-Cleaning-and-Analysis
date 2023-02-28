--The first query selects all columns from the CovidDeaths table and filters for rows where the continent is not null, 
--then sorts the results by the 3rd and 4th columns.

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- The second query selects Location, date, total_cases, new_cases, total_deaths, and population columns 
--from the CovidDeaths table and filters for rows where the continent is not null, 
--then sorts the results by the first and second columns.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--The third query shows the likelihood of dying if one contracts COVID-19 in their country, 
--by selecting Location, date, total_cases, total_deaths, and death percentage columns from the CovidDeaths table, 
--filtered for rows where the location contains the word "states" and the continent is not null. 
--The results are sorted by the first and second columns.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- The fourth query shows what percentage of a country's population is infected with COVID-19 
--by selecting Location, date, population, total_cases, and percent population infected columns from the CovidDeaths table.
--The results are sorted by the first and second columns.


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--The fifth query identifies countries with the highest infection rates compared to their populations 
--by selecting Location, population, the highest infection count, and the percent population infected columns 
--from the CovidDeaths table. The results are grouped by location and population and sorted 
--by the percent population infected column in descending order.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- The sixth query identifies countries with the highest death count per population 
--by selecting Location and total death count columns from the CovidDeaths table. 
--The results are grouped by location and sorted by the total death count column in descending order.

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- The seventh query shows continents with the highest death count per population by selecting continent
--and total death count columns from the CovidDeaths table. 
--The results are grouped by continent and sorted by the total death count column in descending order.


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- The eighth query shows global COVID-19 numbers by selecting the total number of cases, total number of deaths, 
--and the death percentage columns from the CovidDeaths table, filtering for rows where the continent is not null, 
--and sorting by the first two columns.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--The ninth query shows the percentage of a country's population that has received at least one COVID-19 vaccine 
--by selecting columns from the CovidDeaths and CovidVaccinations tables. The results are sorted by location and date.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--The tenth query uses a common table expression (CTE) to perform a calculation on the partition 
--by clause in the ninth query.


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- The eleventh query uses a temporary table to perform a calculation on the partition by clause in the ninth query.


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--The twelfth query creates a view to store data for later visualizations,
--selecting columns from the CovidDeaths and CovidVaccinations tables, filtering for rows where the continent is not null.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

