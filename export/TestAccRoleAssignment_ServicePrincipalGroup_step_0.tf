
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220818234847427869"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "fcc6d3e5-248b-4e06-9240-1a8fb5ad0488"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
