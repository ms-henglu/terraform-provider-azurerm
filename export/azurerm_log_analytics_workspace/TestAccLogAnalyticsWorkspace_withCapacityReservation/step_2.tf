
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034159749948"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                               = "acctestLAW-231016034159749948"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  internet_query_enabled             = false
  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = 5000
}
