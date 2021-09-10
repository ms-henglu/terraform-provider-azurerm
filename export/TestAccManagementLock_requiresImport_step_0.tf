
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021827339203"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210910021827339203"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
