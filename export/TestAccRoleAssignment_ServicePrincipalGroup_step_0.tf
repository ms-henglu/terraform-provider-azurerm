
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220204092645792419"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7cd0dd70-1644-4431-a9b8-f6a31bd3e855"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
