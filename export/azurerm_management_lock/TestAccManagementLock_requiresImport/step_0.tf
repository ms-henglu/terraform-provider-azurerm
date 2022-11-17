
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231417229178"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221117231417229178"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
