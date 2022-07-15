
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220715004832622331"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
