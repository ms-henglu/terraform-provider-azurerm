

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-230915023315406811"
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
  name                         = "acctestAG23091511"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  type                         = "Desktop"
  default_desktop_display_name = "Acceptance Test"
  host_pool_id                 = azurerm_virtual_desktop_host_pool.test.id
}


resource "azurerm_virtual_desktop_application_group" "import" {
  name                = azurerm_virtual_desktop_application_group.test.name
  location            = azurerm_virtual_desktop_application_group.test.location
  resource_group_name = azurerm_virtual_desktop_application_group.test.resource_group_name
  type                = azurerm_virtual_desktop_application_group.test.type
  host_pool_id        = azurerm_virtual_desktop_application_group.test.host_pool_id
}
