
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220324155928089401"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7aba1c71-4f6e-415b-b095-2e8ccbe99e4f"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
