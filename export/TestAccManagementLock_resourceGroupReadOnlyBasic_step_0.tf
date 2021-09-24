
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004809390033"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210924004809390033"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
