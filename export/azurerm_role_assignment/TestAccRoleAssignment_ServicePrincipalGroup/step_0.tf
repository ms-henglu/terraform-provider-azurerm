
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230120051526462174"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "aed8c5bc-ba4c-48f0-aa99-f2b2416ebd56"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
