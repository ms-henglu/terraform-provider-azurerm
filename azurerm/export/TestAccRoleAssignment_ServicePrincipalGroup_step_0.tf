
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-220627131602327850"
}

resource "azurerm_role_assignment" "test" {
  name                 = "d3a387b9-41b4-471d-a13a-fcac8741f3f1"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
