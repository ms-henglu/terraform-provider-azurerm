
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005242542911"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220603005242542911"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
