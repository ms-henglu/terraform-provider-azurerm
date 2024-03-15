
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123944599845"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240315123944599845"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
