
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222219686399"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230316222219686399"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
