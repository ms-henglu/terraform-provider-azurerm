
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005242545982"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220603005242545982"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
