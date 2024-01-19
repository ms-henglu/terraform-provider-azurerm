
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119030025608667"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240119030025608667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-240119030025608667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id

  site_config {
    dotnet_framework_version = "v5.0"
  }
}
