
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211021235431215679"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
