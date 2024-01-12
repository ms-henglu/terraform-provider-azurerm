
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-240112034251004511"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHP"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  validate_environment = true
  description          = "Acceptance Test: A host pool"
  type                 = "Pooled"
  load_balancer_type   = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "test" {
  name                         = "acctestAG24011211"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  type                         = "Desktop"
  host_pool_id                 = azurerm_virtual_desktop_host_pool.test.id
  friendly_name                = "TestAppGroup"
  default_desktop_display_name = "Acceptance Test"
  description                  = "Acceptance Test: An application group"
  tags = {
    Purpose = "Acceptance-Testing"
  }
}
