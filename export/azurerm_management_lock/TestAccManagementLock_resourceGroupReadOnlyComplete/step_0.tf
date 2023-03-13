
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021819922736"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230313021819922736"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
