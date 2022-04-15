
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220415031025504330"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
