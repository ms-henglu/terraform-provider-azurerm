
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220211130213606168"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "c4ca92d5-ac96-4ba0-ab61-ecaf93b372f3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
