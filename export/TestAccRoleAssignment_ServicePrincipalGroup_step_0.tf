
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210924003911433721"
}

resource "azurerm_role_assignment" "test" {
  name                 = "0fb7d09e-cc61-4d8e-ae15-e13c112ad494"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
