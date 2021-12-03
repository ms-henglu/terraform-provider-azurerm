
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211203161046632915"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7387929d-0713-4588-929f-a5b6c1bdf3b2"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
