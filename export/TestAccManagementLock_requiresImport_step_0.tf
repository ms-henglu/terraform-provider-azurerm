
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527024708251585"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220527024708251585"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
