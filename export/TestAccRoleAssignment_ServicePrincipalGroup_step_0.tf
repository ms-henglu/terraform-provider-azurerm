
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220722034834687670"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "f70f3f83-783d-406a-b6c4-3d4a925cae97"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
