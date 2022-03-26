
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220326010132477987"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "0efe9276-4783-42b2-8996-a55d01d74121"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
