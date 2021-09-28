
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210928075203936454"
}

resource "azurerm_role_assignment" "test" {
  name                 = "1b35c2b4-94d5-4262-b263-44ee1cb0f0bc"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
