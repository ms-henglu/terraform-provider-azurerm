
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240119024515582484"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b867c1d6-ffb1-496a-a282-e59004fc4151"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
