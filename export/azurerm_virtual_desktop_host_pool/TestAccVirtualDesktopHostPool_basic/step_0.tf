
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktophp-240119024916085464"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHP0rrcf"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "DepthFirst"
}
