
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022656620421"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210906022656620421"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
