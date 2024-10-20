Select *
From PortfolioProject..[Covid 19 Deaths]
Where continent is not null
Order By 3, 4

Select *
From PortfolioProject..[Covid 19 Vaccinations]
Order By 3, 4

-- Select the data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[Covid 19 Deaths]
Where continent is not null
Order By 1, 2

--Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contact covid in India

Select location, date, total_cases, total_deaths, (total_deaths/Nullif(total_cases,0))*100 as DeathPercentage
From PortfolioProject..[Covid 19 Deaths]
Where location = 'India'
and continent is not null
Order By 1, 2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid in India

Select location, date, population, total_cases, (total_cases/population)*100 as 
    PercentagePopulationInfected
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Order By 1, 2

-- Looking at Countries with the Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as 
   PercentagePopulationInfected
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Group By location, population
Order By PercentagePopulationInfected Desc


--Showing Countries with Highest Death Count as per its Population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Where continent is not null
Group By location
Order By TotalDeathCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENTS
-- Showing continent with the highest death count perpopulation

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Where continent is null
Group By location
Order By TotalDeathCount Desc


-- Global Numbers

Select SUM(new_cases) as total_cases, 
  SUM(new_deaths) as total_deaths, 
  SUM(new_deaths)/Nullif(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Where continent is not null
--Group By date 
Order By 1, 2



-- Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location 
 Order By dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..[Covid 19 Deaths] dea
Join PortfolioProject..[Covid 19 Vaccinations] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3






-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location 
 Order By dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..[Covid 19 Deaths] dea
Join PortfolioProject..[Covid 19 Vaccinations] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location 
 Order By dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..[Covid 19 Deaths] dea
Join PortfolioProject..[Covid 19 Vaccinations] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated



-- Creating View to store data for later visualization
                    
					/*1*/

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location 
 Order By dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..[Covid 19 Deaths] dea
Join PortfolioProject..[Covid 19 Vaccinations] vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3


Select *
From PercentagePopulationVaccinated


                   /*2*/

Create View TotalDeathCount As
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Where continent is not null
Group By location
--Order By TotalDeathCount Desc

Select *
From TotalDeathCount

        
				 /*3*/

Create View GlobalDeathPercentage As
Select SUM(new_cases) as total_cases, 
  SUM(new_deaths) as total_deaths, 
  SUM(new_deaths)/Nullif(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject..[Covid 19 Deaths]
--Where location = 'India'
Where continent is not null
--Group By date 
--Order By 1, 2

Select *
From GlobalDeathPercentage
