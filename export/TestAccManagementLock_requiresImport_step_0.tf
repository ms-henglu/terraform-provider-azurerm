
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429070000395756"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220429070000395756"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
