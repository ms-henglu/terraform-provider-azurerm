
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220204055703962079"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "0b511742-7135-4103-8245-9490f12f0ec0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
