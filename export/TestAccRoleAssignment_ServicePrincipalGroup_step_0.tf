
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220627130801182271"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "524ecf24-1088-48ef-8756-c8dc2bdd2c97"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
