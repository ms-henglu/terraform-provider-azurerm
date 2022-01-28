
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220128052154130216"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "48ec7e3a-4f81-4f74-a5a3-12f2d333f888"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
