
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235431218744"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211021235431218744"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
