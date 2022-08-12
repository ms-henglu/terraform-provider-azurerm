
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220812014637249472"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6bb452a2-4937-4dfd-b0f9-1d805e62ed1b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
