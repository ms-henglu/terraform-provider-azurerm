
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210910021112253935"
}

resource "azurerm_role_assignment" "test" {
  name                 = "3a0b0b1a-418d-4c95-a33f-66549c07e970"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
