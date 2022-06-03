
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005242547436"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220603005242547436"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
