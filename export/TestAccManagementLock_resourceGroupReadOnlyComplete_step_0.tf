
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001054134126428"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211001054134126428"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
