
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220909034908381878"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220909034908381878"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
