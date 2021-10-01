
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224459932585"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211001224459932585"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
