
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422012305552966"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220422012305552966"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
