
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015220115473"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220726015220115473"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
