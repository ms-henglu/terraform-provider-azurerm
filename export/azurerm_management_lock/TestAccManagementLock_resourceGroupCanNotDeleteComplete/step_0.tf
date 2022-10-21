
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034526010606"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221021034526010606"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
