
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035234750130"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221222035234750130"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
