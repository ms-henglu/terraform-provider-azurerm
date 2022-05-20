
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220520053602066484"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "053e93c1-8f46-4338-9791-5e2fce608844"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
