
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044152765683"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231013044152765683"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
