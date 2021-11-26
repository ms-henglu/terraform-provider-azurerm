
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211126030911783938"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "1c1e0a0a-e033-417b-b6a1-424e9286815b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
