
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021819929784"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230313021819929784"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
