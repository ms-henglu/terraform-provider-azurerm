
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220715004138347416"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "aecc0a13-ce50-4e76-a982-5cdd062dd3f1"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
