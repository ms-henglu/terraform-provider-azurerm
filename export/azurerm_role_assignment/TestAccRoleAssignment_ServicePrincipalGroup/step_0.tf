
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221222034237945625"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "5a003857-db77-4e4d-9c0c-3f2f3fef2566"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
