
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230120052631932234"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
