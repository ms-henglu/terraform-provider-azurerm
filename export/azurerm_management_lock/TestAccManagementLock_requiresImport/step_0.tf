
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182231913165"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221124182231913165"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
