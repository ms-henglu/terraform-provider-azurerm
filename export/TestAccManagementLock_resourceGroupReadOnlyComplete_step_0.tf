
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031614840029"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211126031614840029"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
