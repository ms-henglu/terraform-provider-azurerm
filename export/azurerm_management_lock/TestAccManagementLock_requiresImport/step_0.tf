
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052631927096"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230120052631927096"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
