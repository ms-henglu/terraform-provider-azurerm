
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220124124733959160"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "0df780be-494b-4b5f-ac5d-ee24fd21c1aa"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
