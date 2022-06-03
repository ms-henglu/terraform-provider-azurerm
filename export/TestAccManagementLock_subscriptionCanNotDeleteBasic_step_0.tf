
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220603005242543759"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
