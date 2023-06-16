
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230616074256045388"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "990bb68a-de43-4d28-ad4b-a06968a87b4c"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
