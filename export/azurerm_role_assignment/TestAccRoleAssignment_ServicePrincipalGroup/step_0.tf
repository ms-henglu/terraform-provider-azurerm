
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221111020015204835"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b480b299-ec32-4f16-a280-43226723a8e1"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
