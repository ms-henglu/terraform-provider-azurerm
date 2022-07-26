
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220726014514613702"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "cb68c3b4-ea76-4984-b37b-0266a514f0e0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
