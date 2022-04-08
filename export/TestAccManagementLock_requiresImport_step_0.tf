
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051806614147"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220408051806614147"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
