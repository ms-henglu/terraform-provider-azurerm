
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917032136893764"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210917032136893764"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
