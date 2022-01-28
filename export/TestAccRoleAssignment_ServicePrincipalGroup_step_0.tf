
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220128082113123164"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "1957cfc8-6ba8-4a85-8bae-48ae9a8a51e5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
