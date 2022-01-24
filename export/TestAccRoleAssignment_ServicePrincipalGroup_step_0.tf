
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220124121744657652"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "37db41ee-fae5-4bd3-a1b1-f82cd853a3ff"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
