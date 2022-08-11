
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220811052859333243"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "cb2b7a91-c286-485b-be05-c9962391b7f4"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
