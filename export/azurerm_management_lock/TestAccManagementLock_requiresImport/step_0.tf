
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111021108116121"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221111021108116121"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
