
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-220627134233374703"
}

resource "azurerm_role_assignment" "test" {
  name                 = "e73bbd58-02f6-4ead-817b-69bad3a1ef59"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
