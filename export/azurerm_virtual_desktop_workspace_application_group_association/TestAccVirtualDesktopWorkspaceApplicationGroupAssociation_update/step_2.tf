
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-231020040953832813"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctestWS23102013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHPPooled23102013"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  validate_environment = true
  type                 = "Pooled"
  load_balancer_type   = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "test" {
  name                = "acctestAG23102013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  friendly_name       = "TestAppGroup"
  description         = "Acceptance Test: An application group"
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.test.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "test" {
  workspace_id         = azurerm_virtual_desktop_workspace.test.id
  application_group_id = azurerm_virtual_desktop_application_group.test.id
}
