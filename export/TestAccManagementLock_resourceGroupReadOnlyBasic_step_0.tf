
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128053012131717"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220128053012131717"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
