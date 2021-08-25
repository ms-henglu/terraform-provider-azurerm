
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031817205872"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                              = "acctestLAW-210825031817205872"
  location                          = azurerm_resource_group.test.location
  resource_group_name               = azurerm_resource_group.test.name
  internet_query_enabled            = false
  sku                               = "CapacityReservation"
  reservation_capcity_in_gb_per_day = 2300
}
