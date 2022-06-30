
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630224106170368"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220630224106170368"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
