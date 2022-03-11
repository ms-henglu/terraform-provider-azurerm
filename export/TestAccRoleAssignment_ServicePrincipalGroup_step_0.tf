
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220311032104062645"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "2022120c-29c5-4f29-9d37-d5fc59c5bd66"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
