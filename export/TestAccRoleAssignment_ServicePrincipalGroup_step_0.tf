
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220520040349858187"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b4de3635-9fb2-46bc-8109-6ab0009647e0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
