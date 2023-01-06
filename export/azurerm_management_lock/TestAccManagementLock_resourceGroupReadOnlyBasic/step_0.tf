
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031901453155"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230106031901453155"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
