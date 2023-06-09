
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230609091922812032"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
