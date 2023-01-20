
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230120054241031094"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7cbb496b-ef4b-4dc3-9323-66cc47e1e906"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
