
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230613071336756211"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6da4a938-c8a9-4c6d-8756-fca703d4a0a2"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
