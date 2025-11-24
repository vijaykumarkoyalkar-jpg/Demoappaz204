# Deployment Guide for Demoappaz204 to Azure

This document provides multiple options for deploying your ASP.NET Core application to Azure.

## Prerequisites

1. **Azure CLI**: Ensure Azure CLI is installed and you're logged in
   ```bash
   az login
   ```

2. **.NET 7.0 SDK**: Ensure you have .NET 7.0 SDK installed
   ```bash
   dotnet --version
   ```

## Deployment Options

### Option 1: Quick Deployment using PowerShell Script (Windows)

1. Open PowerShell as Administrator
2. Navigate to the project directory
3. Run the deployment script:
   ```powershell
   .\deploy-to-azure.ps1
   ```

### Option 2: Quick Deployment using Bash Script (Linux/macOS)

1. Make the script executable:
   ```bash
   chmod +x deploy-to-azure.sh
   ```
2. Run the script:
   ```bash
   ./deploy-to-azure.sh
   ```

### Option 3: Manual Step-by-Step Deployment

1. **Create Resource Group**
   ```bash
   az group create --name rg-demoappaz204 --location "East US"
   ```

2. **Create App Service Plan**
   ```bash
   az appservice plan create --name asp-demoappaz204 --resource-group rg-demoappaz204 --sku F1 --is-linux
   ```

3. **Create Web App**
   ```bash
   az webapp create --name demoappaz204-[UNIQUE-SUFFIX] --resource-group rg-demoappaz204 --plan asp-demoappaz204 --runtime "DOTNETCORE:7.0"
   ```

4. **Build and Publish the Application**
   ```bash
   cd Demoappaz204
   dotnet build --configuration Release
   dotnet publish --configuration Release --output "./publish"
   ```

5. **Deploy the Application**
   ```bash
   cd publish
   zip -r ../deployment.zip .
   cd ..
   az webapp deployment source config-zip --name demoappaz204-[UNIQUE-SUFFIX] --resource-group rg-demoappaz204 --src "deployment.zip"
   ```

### Option 4: GitHub Actions Deployment (Recommended for CI/CD)

1. **Setup GitHub Secrets**: In your GitHub repository, go to Settings > Secrets and variables > Actions
2. **Get Publish Profile**:
   ```bash
   az webapp deployment list-publishing-profiles --name [YOUR-WEB-APP-NAME] --resource-group rg-demoappaz204 --xml
   ```
3. **Add Secret**: Create a secret named `AZURE_WEBAPP_PUBLISH_PROFILE` with the XML content
4. **Update Workflow**: Modify the web app name in `.github/workflows/azure-webapps-dotnet-core.yml`
5. **Push Changes**: Push your code to trigger the workflow

## Configuration

### Environment Variables

You can configure the following variables in the deployment scripts:

- `RESOURCE_GROUP_NAME`: Azure resource group name (default: "rg-demoappaz204")
- `LOCATION`: Azure region (default: "East US")
- `APP_SERVICE_PLAN_NAME`: App service plan name (default: "asp-demoappaz204")
- `WEB_APP_NAME`: Web app name (will have random suffix for uniqueness)
- `SKU`: App service plan tier (default: "F1" for free tier)

### Production Considerations

For production deployments:

1. **Change SKU**: Use "B1", "S1", or higher instead of "F1"
2. **Custom Domain**: Configure custom domain and SSL certificate
3. **Application Insights**: Enable monitoring
4. **Database**: Configure Azure SQL Database or other database services
5. **Environment Variables**: Set production configuration in App Settings

## Troubleshooting

### Common Issues

1. **Web App Name Already Exists**: The script adds a random suffix to prevent conflicts
2. **Insufficient Permissions**: Ensure your Azure account has Contributor role
3. **Build Failures**: Check .NET SDK version compatibility
4. **Deployment Timeout**: For large applications, consider using GitHub Actions

### Verification

After deployment, verify your application:

1. **Check Application Status**:
   ```bash
   az webapp show --name [YOUR-WEB-APP-NAME] --resource-group rg-demoappaz204 --query "state"
   ```

2. **View Logs**:
   ```bash
   az webapp log tail --name [YOUR-WEB-APP-NAME] --resource-group rg-demoappaz204
   ```

3. **Browse Application**: Visit the provided URL after deployment

## Clean Up

To remove all resources:
```bash
az group delete --name rg-demoappaz204 --yes --no-wait
```

## Support

For issues or questions:
- Check Azure documentation: https://docs.microsoft.com/en-us/azure/app-service/
- Review deployment logs in the Azure portal
- Use Azure CLI help: `az webapp deployment --help`