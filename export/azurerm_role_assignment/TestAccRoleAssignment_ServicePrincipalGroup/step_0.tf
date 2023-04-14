
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230414020758137125"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8a1fb389-db51-4388-bf90-282145eba56e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
