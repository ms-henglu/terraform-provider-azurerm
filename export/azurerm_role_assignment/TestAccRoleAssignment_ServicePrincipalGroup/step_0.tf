
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221104005120471670"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "dd5febe8-d7cd-433d-b3f3-b5e7cb19b5e0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
