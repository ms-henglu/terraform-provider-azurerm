
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506010159623902"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220506010159623902"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
