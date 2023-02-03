
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230203062850606255"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7bf98c1a-de11-4287-8db4-23adad2900a6"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
