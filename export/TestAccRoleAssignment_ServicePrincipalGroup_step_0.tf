
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220506015545362328"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "c51c9391-de01-4c9b-b051-3a45f3b7a949"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
