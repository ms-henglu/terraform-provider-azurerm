
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123944593266"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240315123944593266"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
