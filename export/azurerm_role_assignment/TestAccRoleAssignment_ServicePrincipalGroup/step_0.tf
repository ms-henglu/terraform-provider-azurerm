
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230630032656061105"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "87005576-5f31-4e95-b816-b08f8e7f9bcc"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
