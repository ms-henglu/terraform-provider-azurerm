
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021827333515"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210910021827333515"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
