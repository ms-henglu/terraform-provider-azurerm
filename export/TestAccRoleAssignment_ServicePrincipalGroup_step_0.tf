
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220121044221410222"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "05bd7dda-3a10-41a9-ace4-037210c5d3c2"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
