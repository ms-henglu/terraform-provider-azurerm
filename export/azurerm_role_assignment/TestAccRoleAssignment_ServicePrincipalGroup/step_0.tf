
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240112033853110576"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "91111f32-ac2b-4838-a15b-ea2f71443196"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
