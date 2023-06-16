
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616075639201689"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230616075639201689"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  is_xenon            = true
  kind                = "xenon"

  sku {
    tier = "PremiumV3"
    size = "P1v3"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-230616075639201689"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id

  site_config {
    windows_fx_version = "DOCKER|mcr.microsoft.com/azure-app-service/samples/aspnethelloworld:latest"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://mcr.microsoft.com"
    "DOCKER_REGISTRY_SERVER_USERNAME" = ""
    "DOCKER_REGISTRY_SERVER_PASSWORD" = ""
  }
}
