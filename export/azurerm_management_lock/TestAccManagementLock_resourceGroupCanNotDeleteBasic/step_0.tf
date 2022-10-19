
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019061020140536"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221019061020140536"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
