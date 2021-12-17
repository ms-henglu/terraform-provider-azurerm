
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211217034918532979"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b2f7efc2-6e3c-47fa-ac9b-e684d11ff70a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
