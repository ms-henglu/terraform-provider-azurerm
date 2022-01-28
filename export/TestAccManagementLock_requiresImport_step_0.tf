
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082856203648"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220128082856203648"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
