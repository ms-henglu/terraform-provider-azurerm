
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165453990055"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221028165453990055"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
