
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211015013913030772"
}

resource "azurerm_role_assignment" "test" {
  name                 = "7a888faf-ef88-46cf-a8ce-f60b591c7d2e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
