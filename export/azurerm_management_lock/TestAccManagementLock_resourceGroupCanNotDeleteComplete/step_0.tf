
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204753496480"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221221204753496480"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
