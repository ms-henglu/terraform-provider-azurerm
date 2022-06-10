
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610093200204462"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220610093200204462"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
