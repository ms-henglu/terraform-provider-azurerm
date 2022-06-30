
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220630210500347551"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "cfcc8411-fdad-43c1-b5c2-39c1a5be5183"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
