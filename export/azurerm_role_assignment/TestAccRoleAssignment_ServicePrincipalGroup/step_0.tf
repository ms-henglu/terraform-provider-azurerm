
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221028164609351402"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "f7d4795c-96a6-4c86-bd8a-ea7b3bf66700"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
