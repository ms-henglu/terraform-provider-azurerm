
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033843459561"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230630033843459561"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
