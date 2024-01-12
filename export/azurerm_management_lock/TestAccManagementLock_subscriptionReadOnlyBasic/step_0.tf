
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240112225157598196"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
