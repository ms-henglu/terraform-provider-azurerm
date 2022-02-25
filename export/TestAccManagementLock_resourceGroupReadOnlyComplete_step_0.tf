
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034916558563"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220225034916558563"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
