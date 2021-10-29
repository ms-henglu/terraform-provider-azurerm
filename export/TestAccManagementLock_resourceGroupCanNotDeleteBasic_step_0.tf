
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020111714329"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211029020111714329"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
