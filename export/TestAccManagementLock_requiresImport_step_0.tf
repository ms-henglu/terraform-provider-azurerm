
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004832624134"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220715004832624134"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
