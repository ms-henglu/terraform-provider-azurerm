
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230804025429822945"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "5465ebf4-cad7-4f7c-ba47-42377ab83bc0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
