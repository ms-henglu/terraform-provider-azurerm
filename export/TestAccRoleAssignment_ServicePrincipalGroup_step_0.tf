
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210825042600406398"
}

resource "azurerm_role_assignment" "test" {
  name                 = "b8cb1905-4ef5-45e7-abb3-fa0a5d2b3afd"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
