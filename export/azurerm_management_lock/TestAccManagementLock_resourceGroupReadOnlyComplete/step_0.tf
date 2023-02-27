
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033329460319"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230227033329460319"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
