
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180731882363"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220513180731882363"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
