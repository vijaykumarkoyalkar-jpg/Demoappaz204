# Fixed Azure Deployment Script for Demoappaz204
# This script will create the necessary Azure resources and deploy your ASP.NET Core app

# Configuration variables - modify these as needed
$resourceGroupName = "rg-demoappaz204"
$location = "East US"
$appServicePlanName = "asp-demoappaz204-win"
$webAppName = "demoappaz204-$(Get-Random -Minimum 1000 -Maximum 9999)"  # Adding random suffix to ensure uniqueness
$sku = "B1"  # Basic tier - better than free for production usage

Write-Host "Starting Azure deployment for Demoappaz204..." -ForegroundColor Green
Write-Host "Web App Name will be: $webAppName" -ForegroundColor Yellow

# Check if resource group exists, if not create it
$rgExists = az group exists --name $resourceGroupName
if ($rgExists -eq "false") {
    Write-Host "Creating Resource Group..." -ForegroundColor Blue
    az group create --name $resourceGroupName --location $location
} else {
    Write-Host "Resource Group already exists, skipping creation..." -ForegroundColor Yellow
}

# Step 1: Create App Service Plan (Windows-based for better compatibility)
Write-Host "Creating Windows App Service Plan..." -ForegroundColor Blue
$planResult = az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku $sku --location $location --is-linux $false

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create App Service Plan. Trying with existing plan..." -ForegroundColor Red
    $existingPlan = az appservice plan list --resource-group $resourceGroupName --query "[0].name" -o tsv
    if ($existingPlan) {
        $appServicePlanName = $existingPlan
        Write-Host "Using existing plan: $appServicePlanName" -ForegroundColor Yellow
    }
}

# Step 2: Create Web App
Write-Host "Creating Web App..." -ForegroundColor Blue
$webAppResult = az webapp create --name $webAppName --resource-group $resourceGroupName --plan $appServicePlanName --runtime "DOTNET:7.0"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create Web App. Please check the error messages above." -ForegroundColor Red
    exit 1
}

# Step 3: Configure deployment settings
Write-Host "Configuring deployment..." -ForegroundColor Blue
az webapp config appsettings set --name $webAppName --resource-group $resourceGroupName --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true WEBSITE_WEBDEPLOY_USE_SCM=true

# Step 4: Build and deploy the application
Write-Host "Building and deploying the application..." -ForegroundColor Blue
Push-Location ".\Demoappaz204"

# Build the application
Write-Host "Building application..." -ForegroundColor Cyan
dotnet build --configuration Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Publish the application
Write-Host "Publishing application..." -ForegroundColor Cyan
dotnet publish --configuration Release --output "./publish"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Publish failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Cyan
Compress-Archive -Path "./publish/*" -DestinationPath "../deployment.zip" -Force

Pop-Location

# Deploy the zip package
Write-Host "Deploying to Azure..." -ForegroundColor Cyan
$deployResult = az webapp deployment source config-zip --name $webAppName --resource-group $resourceGroupName --src "deployment.zip"

if ($LASTEXITCODE -eq 0) {
    # Get the web app URL
    $webAppUrl = az webapp show --name $webAppName --resource-group $resourceGroupName --query "defaultHostName" --output tsv

    Write-Host "Deployment completed successfully!" -ForegroundColor Green
    Write-Host "Your application is available at: https://$webAppUrl" -ForegroundColor Yellow
    Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Cyan
    Write-Host "Web App Name: $webAppName" -ForegroundColor Cyan
} else {
    Write-Host "Deployment failed! Please check the error messages above." -ForegroundColor Red
}

# Clean up deployment files
Remove-Item "deployment.zip" -Force -ErrorAction SilentlyContinue

Write-Host "Deployment script completed!" -ForegroundColor Green