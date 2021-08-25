
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825043220600452"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825043220600452"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
