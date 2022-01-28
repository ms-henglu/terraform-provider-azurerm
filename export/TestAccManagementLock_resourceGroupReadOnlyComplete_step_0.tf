
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082856208731"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220128082856208731"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
