
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230313020731664979"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b9ca9d15-b728-439e-980f-d47070d6fa09"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
