
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021031701998810"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221021031701998810"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
