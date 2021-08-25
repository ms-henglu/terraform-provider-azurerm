
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210825044506661079"
}

resource "azurerm_role_assignment" "test" {
  name                 = "0e21fefc-ed08-4f9f-85ba-05be32736581"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
