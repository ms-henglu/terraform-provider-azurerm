
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211112020237692192"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "4d43aab6-e02c-4464-8013-3a0b019a2756"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
