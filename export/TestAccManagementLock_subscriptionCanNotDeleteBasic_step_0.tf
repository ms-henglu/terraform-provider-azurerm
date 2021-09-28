
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210928055846253453"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
