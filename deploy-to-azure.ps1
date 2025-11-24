# Azure Deployment Script for Demoappaz204
# This script will create the necessary Azure resources and deploy your ASP.NET Core app

# Configuration variables - modify these as needed
$resourceGroupName = "rg-demoappaz204"
$location = "East US"
$appServicePlanName = "asp-demoappaz204"
$webAppName = "demoappaz204-$(Get-Random -Minimum 1000 -Maximum 9999)"  # Adding random suffix to ensure uniqueness
$sku = "F1"  # Free tier - change to "B1" or higher for production

Write-Host "Starting Azure deployment for Demoappaz204..." -ForegroundColor Green
Write-Host "Web App Name will be: $webAppName" -ForegroundColor Yellow

# Step 1: Create Resource Group
Write-Host "Creating Resource Group..." -ForegroundColor Blue
az group create --name $resourceGroupName --location $location

# Step 2: Create App Service Plan
Write-Host "Creating App Service Plan..." -ForegroundColor Blue
az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku $sku --is-linux

# Step 3: Create Web App
Write-Host "Creating Web App..." -ForegroundColor Blue
az webapp create --name $webAppName --resource-group $resourceGroupName --plan $appServicePlanName --runtime "DOTNETCORE:7.0"

# Step 4: Configure deployment source (if using local Git)
Write-Host "Configuring deployment..." -ForegroundColor Blue
az webapp config appsettings set --name $webAppName --resource-group $resourceGroupName --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

# Step 5: Build and deploy the application
Write-Host "Building and deploying the application..." -ForegroundColor Blue
Push-Location ".\Demoappaz204"

# Build the application
dotnet build --configuration Release

# Publish the application
dotnet publish --configuration Release --output "./publish"

# Create deployment package
Compress-Archive -Path "./publish/*" -DestinationPath "../deployment.zip" -Force

Pop-Location

# Deploy the zip package
az webapp deployment source config-zip --name $webAppName --resource-group $resourceGroupName --src "deployment.zip"

# Get the web app URL
$webAppUrl = az webapp show --name $webAppName --resource-group $resourceGroupName --query "defaultHostName" --output tsv

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Your application is available at: https://$webAppUrl" -ForegroundColor Yellow
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Cyan
Write-Host "Web App Name: $webAppName" -ForegroundColor Cyan

# Clean up deployment files
Remove-Item "deployment.zip" -Force -ErrorAction SilentlyContinue

Write-Host "Deployment script completed!" -ForegroundColor Green