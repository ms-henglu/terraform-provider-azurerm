
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610023038638746"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220610023038638746"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
