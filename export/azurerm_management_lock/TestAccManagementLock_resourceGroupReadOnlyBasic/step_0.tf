
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204753498709"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221221204753498709"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
