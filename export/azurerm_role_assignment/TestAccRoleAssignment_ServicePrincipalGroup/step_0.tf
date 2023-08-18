
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230818023517085895"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6dedecb9-9dfe-4ac2-bc8d-29078df98c57"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
