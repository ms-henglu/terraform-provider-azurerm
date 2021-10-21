
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235431219914"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211021235431219914"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
