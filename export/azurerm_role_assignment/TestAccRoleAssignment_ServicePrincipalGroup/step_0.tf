
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230316221038384630"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6764155c-baec-4d49-85e3-d33364499eae"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
