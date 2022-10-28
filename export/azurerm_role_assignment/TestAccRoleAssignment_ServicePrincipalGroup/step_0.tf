
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221028171734163425"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7984fc59-e646-4844-8abc-6f9282c629d5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
