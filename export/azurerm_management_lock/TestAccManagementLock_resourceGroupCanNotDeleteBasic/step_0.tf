
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054820848661"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230922054820848661"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
