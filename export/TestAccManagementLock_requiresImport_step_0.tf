
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034411471906"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220107034411471906"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
