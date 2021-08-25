
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210825044513749894"
}

resource "azurerm_role_assignment" "test" {
  name                 = "3282bf8c-1a35-4486-a078-29839ed6df1a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
