
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061453135140"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240105061453135140"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
