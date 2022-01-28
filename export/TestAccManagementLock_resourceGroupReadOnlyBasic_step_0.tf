
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082856201587"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220128082856201587"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
