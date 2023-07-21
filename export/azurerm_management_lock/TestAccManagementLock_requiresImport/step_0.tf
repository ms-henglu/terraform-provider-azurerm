
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015925643546"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230721015925643546"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
