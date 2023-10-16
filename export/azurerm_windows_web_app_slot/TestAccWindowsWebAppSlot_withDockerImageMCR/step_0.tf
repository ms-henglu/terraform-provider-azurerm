
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033329403812"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231016033329403812"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "P1v3"
  os_type             = "WindowsContainer"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-231016033329403812"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-231016033329403812"
  app_service_id = azurerm_windows_web_app.test.id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  site_config {
    application_stack {
      docker_image_name   = "azure-app-service/windows/parkingpage:latest"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }
}
