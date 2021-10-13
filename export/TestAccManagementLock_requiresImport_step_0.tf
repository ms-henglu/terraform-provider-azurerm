
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072330231292"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211013072330231292"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
