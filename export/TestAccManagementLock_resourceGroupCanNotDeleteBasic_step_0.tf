
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035803378489"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211217035803378489"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
