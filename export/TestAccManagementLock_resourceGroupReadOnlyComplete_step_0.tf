
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051806612050"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220408051806612050"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
