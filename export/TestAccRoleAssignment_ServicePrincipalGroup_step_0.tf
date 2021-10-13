
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211013071533245540"
}

resource "azurerm_role_assignment" "test" {
  name                 = "cbf95047-944a-4fbc-bb80-5ff60c66c248"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
