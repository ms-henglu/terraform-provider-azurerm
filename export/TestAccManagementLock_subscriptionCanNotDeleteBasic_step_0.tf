
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211105030459293627"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
