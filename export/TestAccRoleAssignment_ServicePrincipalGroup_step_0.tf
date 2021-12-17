
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211217074912326401"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8e4ea48e-99df-411a-a6c6-220e9acb092b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
