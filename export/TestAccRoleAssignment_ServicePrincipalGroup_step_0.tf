
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220218070432551208"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8b5e1148-8fbd-40d3-b91a-0c8895d30317"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
