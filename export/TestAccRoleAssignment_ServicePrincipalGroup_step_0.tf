
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220408050918067756"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "a7413904-d02d-4a72-a5f8-58d8a3d4de6a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
