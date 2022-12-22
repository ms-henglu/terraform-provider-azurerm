
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035234756643"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221222035234756643"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
