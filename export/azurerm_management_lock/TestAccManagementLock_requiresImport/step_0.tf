
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407024030283669"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230407024030283669"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
