
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210906021951926963"
}

resource "azurerm_role_assignment" "test" {
  name                 = "7ba9a517-1363-4ebe-8dd4-f75ec51a69f0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
