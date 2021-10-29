
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020111714017"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211029020111714017"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
