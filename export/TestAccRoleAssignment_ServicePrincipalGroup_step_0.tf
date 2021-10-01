
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211001223650447589"
}

resource "azurerm_role_assignment" "test" {
  name                 = "bdd81ac9-75d8-44f4-99d6-56034bf70713"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
