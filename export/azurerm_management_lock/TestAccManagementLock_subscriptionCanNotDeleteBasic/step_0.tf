
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230526085758323590"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
