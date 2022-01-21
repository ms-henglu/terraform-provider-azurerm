
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044927519186"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220121044927519186"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
