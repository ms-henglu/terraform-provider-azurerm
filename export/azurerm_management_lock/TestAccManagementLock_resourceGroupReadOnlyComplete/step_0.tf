
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072535879196"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230613072535879196"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
