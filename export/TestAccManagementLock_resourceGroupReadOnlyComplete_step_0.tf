
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042937683300"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220311042937683300"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
