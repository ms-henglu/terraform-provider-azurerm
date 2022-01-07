
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220107033546824159"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "73f58545-3bc4-454e-9571-b6c183287b8c"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
