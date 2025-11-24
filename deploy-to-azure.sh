#!/bin/bash

# Azure Deployment Script for Demoappaz204
# This script will create the necessary Azure resources and deploy your ASP.NET Core app

# Configuration variables - modify these as needed
RESOURCE_GROUP_NAME="rg-demoappaz204"
LOCATION="eastus"
APP_SERVICE_PLAN_NAME="asp-demoappaz204"
WEB_APP_NAME="demoappaz204-$RANDOM"  # Adding random suffix to ensure uniqueness
SKU="F1"  # Free tier - change to "B1" or higher for production

echo "Starting Azure deployment for Demoappaz204..."
echo "Web App Name will be: $WEB_APP_NAME"

# Step 1: Create Resource Group
echo "Creating Resource Group..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Step 2: Create App Service Plan
echo "Creating App Service Plan..."
az appservice plan create --name $APP_SERVICE_PLAN_NAME --resource-group $RESOURCE_GROUP_NAME --sku $SKU --is-linux

# Step 3: Create Web App
echo "Creating Web App..."
az webapp create --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --plan $APP_SERVICE_PLAN_NAME --runtime "DOTNETCORE:7.0"

# Step 4: Configure deployment
echo "Configuring deployment..."
az webapp config appsettings set --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

# Step 5: Build and deploy the application
echo "Building and deploying the application..."
cd ./Demoappaz204

# Build the application
dotnet build --configuration Release

# Publish the application
dotnet publish --configuration Release --output "./publish"

# Create deployment package
cd ./publish
zip -r ../../deployment.zip .
cd ../..

# Deploy the zip package
az webapp deployment source config-zip --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --src "deployment.zip"

# Get the web app URL
WEB_APP_URL=$(az webapp show --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --query "defaultHostName" --output tsv)

echo "Deployment completed successfully!"
echo "Your application is available at: https://$WEB_APP_URL"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Web App Name: $WEB_APP_NAME"

# Clean up deployment files
rm -f deployment.zip

echo "Deployment script completed!"