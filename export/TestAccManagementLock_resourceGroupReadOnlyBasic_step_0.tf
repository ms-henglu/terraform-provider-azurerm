
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064554615856"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220114064554615856"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
