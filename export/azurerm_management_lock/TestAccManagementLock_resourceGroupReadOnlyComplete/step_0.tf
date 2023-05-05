
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505051145890412"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230505051145890412"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
