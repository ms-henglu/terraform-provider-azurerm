
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022656628914"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210906022656628914"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
