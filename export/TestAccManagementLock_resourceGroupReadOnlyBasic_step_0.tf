
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035908422803"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220722035908422803"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
