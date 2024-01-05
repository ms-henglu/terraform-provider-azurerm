
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061453136758"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240105061453136758"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
