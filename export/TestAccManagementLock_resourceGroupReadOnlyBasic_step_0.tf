
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034411475382"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220107034411475382"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
