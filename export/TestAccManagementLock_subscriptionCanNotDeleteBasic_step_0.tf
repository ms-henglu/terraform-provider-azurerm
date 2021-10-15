
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211015014725105314"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
