
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231417228476"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221117231417228476"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
