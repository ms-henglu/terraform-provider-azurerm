
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230227032240754968"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "bb490afa-506c-4d84-9230-4e0f067181e9"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
