
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220603004543016485"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "66b0d3ae-95a7-4862-a742-53801bfc0b1e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
