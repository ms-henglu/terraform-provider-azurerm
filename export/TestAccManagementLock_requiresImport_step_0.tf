
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729033217337205"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220729033217337205"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
