
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022656625825"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210906022656625825"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
