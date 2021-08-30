
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210830084420870262"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
