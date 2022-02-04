
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093500369114"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220204093500369114"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
