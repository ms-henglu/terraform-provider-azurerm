
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230810142938987799"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "17781bcb-184d-416c-88c4-3c01e78b36dd"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
