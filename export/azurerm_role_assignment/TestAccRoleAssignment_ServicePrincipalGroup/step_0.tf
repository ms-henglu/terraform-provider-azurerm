
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231218071242948628"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "5488e756-c710-4b0d-a8f6-02e8e01d6261"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
