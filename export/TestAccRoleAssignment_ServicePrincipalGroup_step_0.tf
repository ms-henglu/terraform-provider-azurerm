
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220324175940271350"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "e3fdcd63-e0df-4b36-a51a-87e35c9952a2"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
