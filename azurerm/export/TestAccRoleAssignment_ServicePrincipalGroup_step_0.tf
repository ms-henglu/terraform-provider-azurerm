
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-220627125633926729"
}

resource "azurerm_role_assignment" "test" {
  name                 = "e8ece658-a0ea-4853-a8e8-ea96d583d127"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
