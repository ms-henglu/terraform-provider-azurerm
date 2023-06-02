
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230602030139961124"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "609c7c72-0955-43de-a896-c4121a7bbb95"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
