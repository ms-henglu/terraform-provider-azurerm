
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220715014156300204"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6586c244-b6c2-44b5-8161-e3aa965d0938"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
