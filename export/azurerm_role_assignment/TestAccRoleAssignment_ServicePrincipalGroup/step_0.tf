
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230728031752021098"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "435887db-0290-48b6-a8c2-5db69abcfba4"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
