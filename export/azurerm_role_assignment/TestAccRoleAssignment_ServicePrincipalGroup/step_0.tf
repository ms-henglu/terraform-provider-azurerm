
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230922060618361239"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8b1fcea4-a940-4ebb-99e3-6fb7891a6628"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
