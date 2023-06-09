
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091922818918"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230609091922818918"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
