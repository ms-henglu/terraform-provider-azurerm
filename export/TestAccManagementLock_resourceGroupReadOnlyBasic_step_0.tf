
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211131123013287"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220211131123013287"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
