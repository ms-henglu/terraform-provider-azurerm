
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033843458713"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230630033843458713"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
