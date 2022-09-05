
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905050415864514"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220905050415864514"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
