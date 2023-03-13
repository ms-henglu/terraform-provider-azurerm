
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313022056766086"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230313022056766086"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestAS-230313022056766086"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_slot" "test" {
  name                    = "acctestASSlot-230313022056766086"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  app_service_plan_id     = azurerm_app_service_plan.test.id
  app_service_name        = azurerm_app_service.test.name
  client_affinity_enabled = true
}
