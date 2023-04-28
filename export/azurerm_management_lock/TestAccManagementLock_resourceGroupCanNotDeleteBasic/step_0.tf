
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050439834305"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230428050439834305"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
