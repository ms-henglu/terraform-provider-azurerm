
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825032033099227"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825032033099227"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
