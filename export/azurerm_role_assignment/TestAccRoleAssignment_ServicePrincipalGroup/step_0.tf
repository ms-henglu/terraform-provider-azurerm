
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221117230517458002"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b2fb22ed-3a0f-4474-b2c9-eba68e14f869"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
