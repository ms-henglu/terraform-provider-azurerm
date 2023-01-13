
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230113180728725657"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "67ab9ba9-627f-4e82-a70c-2dc1788f9698"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
