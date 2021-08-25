
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825030142436756"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
