
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235431217490"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211021235431217490"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
