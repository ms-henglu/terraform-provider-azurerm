

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktophp-230106031358036780"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHPl4gu6"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "BreadthFirst"
}


resource "azurerm_virtual_desktop_host_pool" "import" {
  name                 = azurerm_virtual_desktop_host_pool.test.name
  location             = azurerm_virtual_desktop_host_pool.test.location
  resource_group_name  = azurerm_virtual_desktop_host_pool.test.resource_group_name
  validate_environment = azurerm_virtual_desktop_host_pool.test.validate_environment
  type                 = azurerm_virtual_desktop_host_pool.test.type
  load_balancer_type   = azurerm_virtual_desktop_host_pool.test.load_balancer_type
}
