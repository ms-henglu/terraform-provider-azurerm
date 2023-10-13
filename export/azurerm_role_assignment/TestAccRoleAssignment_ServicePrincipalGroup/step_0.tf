
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231013042942892303"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "ce2a008a-7bf8-4008-8450-aee87b43cbba"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
