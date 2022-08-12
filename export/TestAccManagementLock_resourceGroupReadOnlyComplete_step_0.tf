
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015659779680"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220812015659779680"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
