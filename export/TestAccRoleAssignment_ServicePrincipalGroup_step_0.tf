
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220905045429463050"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b57457ce-7223-456f-b40d-695ab722c344"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
