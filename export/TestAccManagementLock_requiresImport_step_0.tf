
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022656623622"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210906022656623622"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
