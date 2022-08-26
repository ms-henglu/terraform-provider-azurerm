
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktophp-220826002635212022"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHPjped2"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "BreadthFirst"
}
