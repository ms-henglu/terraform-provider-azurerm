
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240112223948225936"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "f154604d-fd0b-4559-9c9f-76e46d136bcd"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
