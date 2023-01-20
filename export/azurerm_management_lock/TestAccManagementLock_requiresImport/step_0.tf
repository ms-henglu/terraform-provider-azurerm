
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120055048128245"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230120055048128245"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
