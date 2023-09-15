
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022839992674"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-230915022839992674"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230915022839992674"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-230915022839992674"
  app_service_id = azurerm_windows_web_app.test.id

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  site_config {
    application_stack {
      dotnet_version = "v6.0"
      current_stack  = "dotnet"
    }
  }

  zip_deploy_file = "./testdata/dotnet-zipdeploy.zip"
}

