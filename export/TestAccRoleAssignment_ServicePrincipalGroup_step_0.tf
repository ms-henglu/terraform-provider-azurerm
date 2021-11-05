
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211105025642794861"
}

resource "azurerm_role_assignment" "test" {
  name                 = "ad636660-45a5-4cc6-8179-eb2e0f2ace8e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
