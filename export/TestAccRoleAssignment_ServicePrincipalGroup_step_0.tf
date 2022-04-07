
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220407230703789490"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "e17219c0-7a40-44a4-9257-e357f80a527b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
