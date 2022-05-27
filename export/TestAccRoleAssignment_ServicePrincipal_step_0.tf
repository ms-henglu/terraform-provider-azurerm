
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_application" "test" {
  display_name = "acctestspa-220527033831534478"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_role_assignment" "test" {
  name                 = "dd23c133-0fac-4883-ae80-9eafbf684f64"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id
}
