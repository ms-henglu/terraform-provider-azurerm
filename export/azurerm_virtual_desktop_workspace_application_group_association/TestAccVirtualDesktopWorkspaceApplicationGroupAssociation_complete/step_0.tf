
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-231020040953831530"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctestWS23102030"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHPPooled23102030"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  validate_environment = true
  type                 = "Pooled"
  load_balancer_type   = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "test" {
  name                = "acctestAG23102030"
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

resource "azurerm_virtual_desktop_host_pool" "personal" {
  name                             = "acctestHP2nd23102030"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  type                             = "Personal"
  personal_desktop_assignment_type = "Automatic"
  load_balancer_type               = "Persistent"
}

resource "azurerm_virtual_desktop_application_group" "personal" {
  name                = "acctestAG2nd23102030"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  friendly_name       = "TestAppGroup"
  description         = "Acceptance Test: An application group"
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.personal.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "personal" {
  workspace_id         = azurerm_virtual_desktop_workspace.test.id
  application_group_id = azurerm_virtual_desktop_application_group.personal.id
}
