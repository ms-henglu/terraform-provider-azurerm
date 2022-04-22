
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220422011556043854"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "949aa500-31a8-44c2-bec5-c7f214c5c5a8"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
