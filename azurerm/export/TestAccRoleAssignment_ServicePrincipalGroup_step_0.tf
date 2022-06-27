
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-220627122411303843"
}

resource "azurerm_role_assignment" "test" {
  name                 = "928c9b9c-ae36-4fab-8a63-8014bcdb7833"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
