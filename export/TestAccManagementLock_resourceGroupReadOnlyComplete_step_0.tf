
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125555643212"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220124125555643212"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
