
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221111014148920729"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
