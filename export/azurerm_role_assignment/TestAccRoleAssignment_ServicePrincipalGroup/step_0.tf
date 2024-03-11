
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240311031355094932"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "e1522317-8818-4660-ba34-94572b052d20"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
