
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519075534067123"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230519075534067123"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
