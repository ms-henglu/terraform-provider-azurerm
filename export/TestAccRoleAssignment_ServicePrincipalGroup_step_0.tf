
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220916011112709291"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "f95b133c-fd38-4fd1-823b-247c0fba7787"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
