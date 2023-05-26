
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085758325239"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230526085758325239"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
