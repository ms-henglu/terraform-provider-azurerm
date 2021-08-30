
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210830083701098758"
}

resource "azurerm_role_assignment" "test" {
  name                 = "4c67e58a-2f0a-4931-a7ea-9355feba8577"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
