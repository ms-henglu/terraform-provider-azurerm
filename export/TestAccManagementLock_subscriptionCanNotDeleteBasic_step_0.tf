
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220407231401259976"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
