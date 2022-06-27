
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-220627131828788918"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                = "acctestHP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "test" {
  name                = "acctestAG22062718"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.test.id
}
