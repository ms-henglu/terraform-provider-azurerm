
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025258337719"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                               = "acctestLAW-240119025258337719"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  internet_query_enabled             = false
  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = 100
}
