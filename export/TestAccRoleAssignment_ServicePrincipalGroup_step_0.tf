
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220114063834265872"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "deae8ac0-1c0b-492e-b592-c5a2a9248b4d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
