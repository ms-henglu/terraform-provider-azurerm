
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051341557674"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211119051341557674"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
