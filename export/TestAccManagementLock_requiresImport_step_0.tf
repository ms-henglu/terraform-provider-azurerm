
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075851708565"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210928075851708565"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
