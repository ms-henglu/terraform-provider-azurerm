
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220923011526157473"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "20b7ca5b-20eb-4b7b-9285-93c5cbe3281a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
