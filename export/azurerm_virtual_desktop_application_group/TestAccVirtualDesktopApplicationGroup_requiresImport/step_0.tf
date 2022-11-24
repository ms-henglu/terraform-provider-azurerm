
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-221124181551796123"
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
  name                         = "acctestAG22112423"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  type                         = "Desktop"
  default_desktop_display_name = "Acceptance Test"
  host_pool_id                 = azurerm_virtual_desktop_host_pool.test.id
}
