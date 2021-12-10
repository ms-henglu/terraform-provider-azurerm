
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025007604264"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211210025007604264"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
