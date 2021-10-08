
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211008044052024952"
}

resource "azurerm_role_assignment" "test" {
  name                 = "2d24fc4c-8d16-4e9e-8ca8-9a256dbf32c1"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
