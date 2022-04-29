
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429075845937746"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220429075845937746"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
