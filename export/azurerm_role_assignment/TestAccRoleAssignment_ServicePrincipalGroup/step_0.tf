
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230922053619995032"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7fcd08ed-b9b2-4076-8d0c-c909c79a24ab"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
