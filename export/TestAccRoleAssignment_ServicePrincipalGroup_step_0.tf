
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210826023102335255"
}

resource "azurerm_role_assignment" "test" {
  name                 = "43055f51-e03c-4c42-af07-2be18ce0733a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
