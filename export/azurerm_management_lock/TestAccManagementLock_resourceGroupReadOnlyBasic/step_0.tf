
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030621598401"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230804030621598401"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
