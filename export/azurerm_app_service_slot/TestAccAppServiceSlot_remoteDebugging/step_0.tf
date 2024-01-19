
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119030025618543"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240119030025618543"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-240119030025618543"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_slot" "test" {
  name                = "acctestASSlot-240119030025618543"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
  app_service_name    = azurerm_app_service.test.name

  site_config {
    remote_debugging_enabled = true
    remote_debugging_version = "VS2019"
  }

  tags = {
    Hello = "World"
  }
}
