
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230316222219687446"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
