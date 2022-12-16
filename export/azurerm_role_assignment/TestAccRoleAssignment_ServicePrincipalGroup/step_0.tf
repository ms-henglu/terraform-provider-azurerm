
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221216013111075014"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "2b41885e-39c5-4dc3-a3ea-b91de00b097e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
