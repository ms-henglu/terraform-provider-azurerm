
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024120282278"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230915024120282278"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
