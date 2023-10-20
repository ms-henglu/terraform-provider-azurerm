
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231020040545365859"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "a07e0f08-aa24-4173-90e1-55c8ee00325e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
