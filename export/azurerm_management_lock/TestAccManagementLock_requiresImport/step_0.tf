
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022750525035"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240119022750525035"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
