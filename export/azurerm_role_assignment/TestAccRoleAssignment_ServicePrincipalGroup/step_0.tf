
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230929064400656388"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "653e81d2-f371-4965-b407-431d3ed6a9d9"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
