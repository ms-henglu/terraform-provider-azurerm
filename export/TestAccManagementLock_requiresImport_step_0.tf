
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031614849716"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211126031614849716"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
