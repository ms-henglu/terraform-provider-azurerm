
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230602031016741430"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
