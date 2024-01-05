
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240105061453136064"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
