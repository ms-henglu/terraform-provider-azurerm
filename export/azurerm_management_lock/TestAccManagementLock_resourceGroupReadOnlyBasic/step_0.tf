
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034949872595"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230106034949872595"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
