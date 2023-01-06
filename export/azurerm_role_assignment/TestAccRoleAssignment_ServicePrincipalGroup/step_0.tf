
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230106031129875140"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "fa438f76-5711-4a80-8186-067eed2c9533"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
