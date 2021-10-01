
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001054134121506"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211001054134121506"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
