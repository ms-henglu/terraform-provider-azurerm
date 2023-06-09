
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230609090833457204"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "3bc277ad-7cde-4b45-ac33-e94f4c48cc5b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
