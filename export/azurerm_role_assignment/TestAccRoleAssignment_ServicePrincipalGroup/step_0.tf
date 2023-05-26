
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230526084616501665"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "915c5652-5ea3-4721-aa1d-c1391bdd31d9"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
