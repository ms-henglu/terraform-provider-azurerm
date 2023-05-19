
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230519074214073629"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8fd7f3b8-85cd-409a-a195-78ac9a23738a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
