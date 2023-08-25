
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025220309050"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230825025220309050"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
