
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506020419779448"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220506020419779448"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
