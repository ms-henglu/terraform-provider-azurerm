
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505051145890630"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230505051145890630"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
