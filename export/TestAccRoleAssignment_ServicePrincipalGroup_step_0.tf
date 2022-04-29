
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220429065156059330"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "94f52295-f3b9-4cf4-87e5-9c918ec9b8dc"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
