
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161829265750"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211203161829265750"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
