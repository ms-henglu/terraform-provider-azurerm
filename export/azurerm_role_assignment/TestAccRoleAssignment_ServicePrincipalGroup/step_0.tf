
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230728025052150910"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "659fa601-4c90-4515-8928-79d42decdcd3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
