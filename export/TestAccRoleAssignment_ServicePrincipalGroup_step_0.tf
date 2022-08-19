
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220819164917642699"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "8cdcc1a8-f861-46fc-bafc-ef607e5076e5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
