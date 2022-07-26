
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726002408865601"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220726002408865601"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
