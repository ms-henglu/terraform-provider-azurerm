
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220324162946597690"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "4f0f205d-cf2f-41cb-9659-7a0673ed649e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
