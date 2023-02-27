
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175929560203"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230227175929560203"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
