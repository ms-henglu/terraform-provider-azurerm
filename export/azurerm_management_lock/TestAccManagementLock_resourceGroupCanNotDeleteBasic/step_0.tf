
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035234751908"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221222035234751908"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
